{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;

  sunscreen = pkgs.writeShellScriptBin "sunscreen" ''
    WIDTH=''${SUNSHINE_CLIENT_WIDTH:-1920}
    HEIGHT=''${SUNSHINE_CLIENT_HEIGHT:-1080}
    FPS=''${SUNSHINE_CLIENT_FPS:-60}.000

    if [ "$1" == "reset" ]; then
      # Reset profile
      PROFILE="2560x1080@74.991+vrr"
    else
      # Generate profile
      PROFILE="''${WIDTH}x''${HEIGHT}@''${FPS}"
    fi

    ${pkgs.gnome-monitor-config}/bin/gnome-monitor-config set -LpM DP-3 -m ''${PROFILE}
  '';
in
{
  config = lib.mkIf (cfg.gaming.enable && cfg.gaming.streaming) {
    services.sunshine = {
      enable = true;
      autoStart = false;
      capSysAdmin = true;
      openFirewall = true;
    };

    # Apps
    services.sunshine.applications = {
      env = {
        PATH = "$(PATH):/run/current-system/sw/bin";
      };
      apps = [
        {
          name = "Desktop";
          image-path = "desktop.png";
          prep-cmd = [
            {
              do = "${sunscreen}/bin/sunscreen";
              undo = "${sunscreen}/bin/sunscreen reset";
            }
          ];
          exclude-global-prep-cmd = "";
          auto-detach = "true";
          wait-all = "true";
          exit-timeout = "5";
        }
        {
          name = "Steam Big Picture";
          image-path = "steam.png";
          prep-cmd = [
            {
              do = "${sunscreen}/bin/sunscreen";
              undo = "${sunscreen}/bin/sunscreen reset";
            }
          ];
          detached = [ "steam steam://open/bigpicture" ];
          exclude-global-prep-cmd = "";
          auto-detach = "true";
          wait-all = "true";
          exit-timeout = "5";
        }
      ];
    };
  };
}
