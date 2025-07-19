{ config, pkgs, lib, ... }:
let
  cfg = {
    gaming = config.modules.desktop.gaming;
    graphics = config.modules.graphics;
  };

  sunscreen = pkgs.writeShellScriptBin "sunscreen" ''
    WIDTH=''${SUNSHINE_CLIENT_WIDTH:-1920}
    HEIGHT=''${SUNSHINE_CLIENT_HEIGHT:-1080}
    FPS=''${SUNSHINE_CLIENT_FPS:-60}

    # Generate profile
    PROFILE="''${WIDTH}x''${HEIGHT}@''${FPS}"

    ${pkgs.easyeffects}/bin/easyeffects -r
    hyprctl keyword monitor HEADLESS-2,''$PROFILE,auto,auto
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
