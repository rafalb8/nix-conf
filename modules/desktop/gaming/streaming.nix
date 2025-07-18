{ config, pkgs, lib, ... }:
let
  cfg = {
    gaming = config.modules.desktop.gaming;
    graphics = config.modules.graphics;
  };

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

    ${pkgs.easyeffects}/bin/easyeffects -r
    MONITOR=''$(${pkgs.gnome-monitor-config}/bin/gnome-monitor-config list | grep 'Monitor' | awk '{print $3}')
    ${pkgs.gnome-monitor-config}/bin/gnome-monitor-config set -LpM ''${MONITOR} -m ''${PROFILE}
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

    # Settings
    # https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2configuration.html
    # services.sunshine.settings = lib.mkIf cfg.graphics.amd {
    #   capture = "kms";
    #   encoder = "vaapi";
    # };

    home-manager.users.${config.user.name} = {
      xdg = {
        enable = true;

        # Custom sunshine desktop entry
        desktopEntries."dev.lizardbyte.app.Sunshine" = {
          name = "Sunshine";
          icon = "sunshine";
          exec = "systemctl restart --user sunshine.service";
          comment = "Self-hosted game stream host for Moonlight";
          categories = [ "AudioVideo" "Network" "RemoteAccess" "Game" ];
        };
      };
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
          detached = [ "setsid steam steam://open/bigpicture" ];
          exclude-global-prep-cmd = "";
          auto-detach = "true";
          wait-all = "true";
          exit-timeout = "5";
        }
      ];
    };
  };
}
