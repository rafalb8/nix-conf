{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  imports = [ ./streaming.nix ./mangohud.nix ./experiments.nix ];

  config = lib.mkIf cfg.gaming.enable {
    boot.kernelParams = [ "split_lock_detect=off" ];

    environment.systemPackages = with pkgs; [
      # Tools
      prismlauncher # Minecraft launcher
      custom.sgdboop
      # protonup-qt

      # Wine guis
      bottles
      heroic
      # lutris

      # Emulators
      rpcs3
    ];

    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        protontricks.enable = true;
        extraCompatPackages = with pkgs; [
          steamtinkerlaunch
          proton-ge-bin
        ];
      };

      gamemode.enable = true;
      gamemode.enableRenice = true;
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
        packages = [ pkgs.steam ];
      };
    };

  };
}
