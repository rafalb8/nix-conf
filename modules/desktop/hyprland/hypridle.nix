{ config, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.environment.hyprland {
    services.hypridle.enable = true;
    home-manager.users.${config.user.name} = {
      xdg.configFile."hypr/hypridle.conf".text = ''
        general {
            lock_cmd = hyprlock
            before_sleep_cmd = loginctl lock-session
            after_sleep_cmd = hyprctl dispatch dpms on
        }

        listener {
            timeout = 300
            on-timeout = brightnessctl -s set 10%
            on-resume = brightnessctl -r
        }

        listener {
            timeout = 600
            on-timeout = hyprctl dispatch dpms off
            on-resume = hyprctl dispatch dpms on
        }

        listener {
            timeout = 900
            on-timeout = loginctl lock-session
        }
      '';
    };
  };
}
