{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  imports = [ ./streaming.nix ];

  config = lib.mkIf cfg.gaming.enable {

    environment.systemPackages = with pkgs; [
      edge.prismlauncher
      edge.protontricks
      mesa-demos
      edge.mangohud
      # edge.bottles
      edge.heroic
      edge.lutris
      custom.sgdboop
    ];

    programs.steam = {
      enable = true;
    };

    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };


    home-manager.users.${config.user.name} = {
      xdg = {
        enable = true;

        # Configure MangoHud
        configFile."MangoHud" = {
          source = ../../../dotfiles/MangoHud;
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
