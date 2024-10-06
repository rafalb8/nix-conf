{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;

  sunscreen = pkgs.writeShellScriptBin "sunscreen" ''
    WIDTH=''${SUNSHINE_CLIENT_WIDTH:-2560}
    HEIGHT=''${SUNSHINE_CLIENT_HEIGHT:-1080}
    FPS=''${SUNSHINE_CLIENT_FPS:-75}

    # Turn off easyeffects
    easyeffects -q

    if [ "$1" != "reset" ]; then
      # Generate profile
      PROFILE="''${WIDTH}x''${HEIGHT}_''${FPS}"
    else
      # Reset profile
      PROFILE="2560x1080_75"
    fi

    nvidia-settings --assign CurrentMetaMode="DP-0: ''${PROFILE} {ForceCompositionPipeline=Off, AllowGSYNCCompatible=Off}"
  '';
in
{
  config = lib.mkIf (cfg.gaming.enable && cfg.gaming.streaming) {
    services.sunshine = {
      enable = true;
      autoStart = false;
      openFirewall = true;

      package = pkgs.custom.sunshine;
    };

    # Settings
    services.sunshine.settings = {
      capture = "nvfbc";
      encoder = "nvenc";
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
