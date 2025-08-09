{ config, pkgs, lib, ... }:
let
  cfg = {
    gaming = config.modules.desktop.gaming;
    graphics = config.modules.graphics;
  };

  sunscreen = pkgs.writeShellScriptBin "sunscreen" ''
    # Restart current script without CAP_SYS_ADMIN
    if getpcaps $$ | grep -q "cap_sys_admin"; then
      exec setpriv --inh-caps -sys_admin "$0" "$@"
    fi

    WIDTH=''${SUNSHINE_CLIENT_WIDTH:-$(hyprctl monitors -j | jq ".[0].width")}
    HEIGHT=''${SUNSHINE_CLIENT_HEIGHT:-$(hyprctl monitors -j | jq ".[0].height")}
    FPS=''${SUNSHINE_CLIENT_FPS:-$(hyprctl monitors -j | jq ".[0].refreshRate | tonumber")}
    PROFILE="''${WIDTH}x''${HEIGHT}@''${FPS}"

    case $1 in
      "reset") pkill -TERM gamescope ;;
      "mode") hyprctl keyword monitor HEADLESS-2, ''${PROFILE}, auto, 1 ;;
      "steam")
        pkill -TERM steam && pidwait steam && sleep 3
        export MANGOHUD_CONFIG=preset=1
        exec gamescope -W ''${WIDTH} -H ''${HEIGHT} -r ''${FPS} \
            --immediate-flips --force-grab-cursor --disable-color-management \
            --mangoapp -e -f -- steam -gamepadui ;;
      *) exec "$@"
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


    services.sunshine = {
      # https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2configuration.html
      settings = {
        back_button_timeout = 2000;
        mouse = "disabled";
      };

      # 
      applications = {
        env = {
          PATH = "$(PATH):/run/current-system/sw/bin";
        };
        apps = [
          {
            name = "Desktop";
            image-path = "desktop.png";
            prep-cmd = [
              {
                do = ''${sunscreen}/bin/sunscreen mode'';
                undo = "${sunscreen}/bin/sunscreen reset";
              }
            ];
            detached = [ "alacritty" ];
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
            detached = [ "${sunscreen}/bin/sunscreen steam" ];
            exclude-global-prep-cmd = "";
            auto-detach = "true";
            wait-all = "true";
            exit-timeout = "5";
          }
        ];
      };
    };

    # Fix for DS4/DS5 gamepads
    boot.kernelModules = [ "uhid" ];

    # Configure hyperland for streaming
    environment.systemPackages = [ pkgs.hyprland sunscreen ];
    home-manager.users.${config.user.name} = {
      xdg = {
        enable = true;

        configFile."hypr/hyprland.conf".text = ''
          monitor = HEADLESS-2, 1920x1080@60, auto, 1
          monitor = WAYLAND-1, disabled
          monitor = , preferred, auto, auto
          # monitor = , disabled

          # Create Headless monitor and disable the WAYLAND-1
          exec-once = hyprctl output create headless HEADLESS-2
          exec-once = hyprctl keyword monitor DP-1, disabled

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

          # Gamescope fix
          debug:full_cm_proto = true
        '';
      };
    };

  };
}
