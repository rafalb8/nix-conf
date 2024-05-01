{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.gaming.enable {

    environment.systemPackages = with pkgs; [
      prismlauncher
      protontricks
      mangohud
      bottles
    ];

    programs.steam.enable = true;

    home-manager.users.${config.user.name} = {
      imports = [
        ../home/autostart.nix
      ];

      xdg = {
        enable = true;

        # Configure MangoHud
        configFile."MangoHud" = {
          source = ../../dotfiles/MangoHud;
          recursive = true;
        };

        # Steam custom desktop entry
        desktopEntries.steam = {
          name = "Steam";
          icon = "steam";
          exec = "env MANGOHUD=1 steam -silent %U";
          terminal = false;
          categories = [ "Network" "FileTransfer" "Game" ];
          mimeType = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ];
          actions = {
            "Store" = { exec = "steam steam://store"; };
            "Library" = { exec = "steam steam://open/games"; };
            "Friends" = { exec = "steam steam://open/friends"; };
            "Settings" = { exec = "steam steam://open/settings"; };
            "BigPicture" = {
              name = "Big Picture";
              exec = "steam steam://open/bigpicture";
            };
          };
        };
      };

      # Autostart
      autostart = {
        enable = true;
        packages = [
          pkgs.steam
        ];
      };

    };

  };
}
