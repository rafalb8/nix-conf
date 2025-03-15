{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  imports = [ ./streaming.nix ./mangohud.nix ];

  config = lib.mkIf cfg.gaming.enable {

    environment.systemPackages = with pkgs; [
      # Tools
      edge.prismlauncher
      edge.mesa-demos
      custom.sgdboop

      # Wine guis
      edge.bottles
      edge.heroic
      # edge.lutris
    ];

    # VR
    # programs.alvr = {
    #   enable = true;
    #   openFirewall = true;
    #   package = pkgs.edge.alvr;
    # };

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;

      protontricks = {
        enable = true;
        package = pkgs.edge.protontricks;
      };

      gamescopeSession = {
        enable = true;
        args = [
          "--adaptive-sync"
          "--hdr-enabled"
          "--mangoapp"
          "--rt"
          "-r 75"
        ];
      };
    };

    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    home-manager.users.${config.user.name} = {
      xdg = {
        enable = true;

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
