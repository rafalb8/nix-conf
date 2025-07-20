{ config, pkgs, lib, ... }:
let
  cfg = {
    gaming = config.modules.desktop.gaming;
    graphics = config.modules.graphics;
  };

  sunscreen = pkgs.writeShellScriptBin "sunscreen" ''
    MON="hyprctl monitors -j"

    WIDTH=''${SUNSHINE_CLIENT_WIDTH:-$($MON | jq ".[0].width")}
    HEIGHT=''${SUNSHINE_CLIENT_HEIGHT:-$($MON | jq ".[0].height")}
    FPS=''${SUNSHINE_CLIENT_FPS:-$($MON | jq ".[0].refreshRate | tonumber")}
    PROFILE="''${WIDTH}x''${HEIGHT}@''${FPS}"

    case $1 in
      "reset") pkill --signal SIGTERM gamescope ;;
      "mode") hyprctl keyword monitor HEADLESS-2, ''${PROFILE}, auto, 1 ;;
      *) pkill --signal SIGTERM steam; sleep 3; gamescope --backend=sdl -e -f -W ''${WIDTH} -H ''${HEIGHT} -r ''${FPS} -- steam -gamepadui
    esac
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

    environment.systemPackages = [ pkgs.hyprland sunscreen ];

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

        configFile."hypr/hyprland.conf".text = ''
          monitor = WAYLAND-1, preferred, auto, auto
          monitor = HEADLESS-2, 1920x1080@60, auto, 1
          monitor = , disabled
          # monitor = , preferred, auto, auto

          # Create Headless monitor and disable the WAYLAND-1
          exec-once = hyprctl output create headless HEADLESS-2
          exec-once = hyprctl keyword monitor WAYLAND-1, disabled

          # Start programs
          # exec-once = systemctl restart --user sunshine.service
          exec-once = ${config.systemd.user.services.sunshine.serviceConfig.ExecStart}

          bind = SUPER, W, killactive
          bind = CTRL ALT, Delete, exit
          bind = SUPER, T, exec, alacritty
          bind = SUPER, S, exec, sunscreen # Start Gamescope Steam

          binde = SUPER, Tab, cyclenext
          binde = SUPER, Tab, bringactivetotop

          bindm = SUPER, mouse:272, movewindow
          bindm = SUPER, mouse:273, resizewindow
        '';
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
          name = "Steam";
          image-path = "steam.png";
          prep-cmd = [
            {
              do = ''${sunscreen}/bin/sunscreen mode'';
              undo = "${sunscreen}/bin/sunscreen reset";
            }
          ];
          detached = [ "${sunscreen}/bin/sunscreen" ];
          exclude-global-prep-cmd = "";
          auto-detach = "true";
          wait-all = "true";
          exit-timeout = "5";
        }
      ];
    };
  };
}
