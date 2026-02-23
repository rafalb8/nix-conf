{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.environment.hyprland {
    environment.systemPackages = with pkgs; [ hypridle ];
    home-manager.users.${config.user.name} = {
      xdg.configFile."hypr/hypridle.conf".text = ''
        general {
            lock_cmd = pidof hyprlock || hyprlock
            before_sleep_cmd = loginctl lock-session
            after_sleep_cmd = hyprctl dispatch dpms on
        }

        # Screen
        listener {
            timeout = 60
            on-timeout = brightnessctl -s set 10
            on-resume = brightnessctl -r
        }

        # Keyboard backlight
        listener {
            timeout = 30
            on-timeout = brightnessctl -sd tpacpi::kbd_backlight set 0
            on-resume = brightnessctl -rd tpacpi::kbd_backlight
            ignore_inhibit = true
        }

        listener {
            timeout = 300
            on-timeout = loginctl lock-session
        }

        listener {
            timeout = 330
            on-timeout = hyprctl dispatch dpms off
            on-resume = hyprctl dispatch dpms on && brightnessctl -r
        }

        # Suspend
        listener {
            timeout = 1800
            on-timeout = systemctl suspend
        }
      '';
    };
  };
}
