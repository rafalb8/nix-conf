{ config, lib, pkgs, ... }:
let
  cfg = config.modules.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ hypridle ];
    systemd.user.services."hypridle".enable = false;
    home-manager.users."rafalb8" = {
      xdg.configFile."hypr/hypridle.conf".text = ''
        general {
            lock_cmd = pidof hyprlock || hyprlock
            before_sleep_cmd = loginctl lock-session
            after_sleep_cmd = hyprctl dispatch dpms on
        }

        # Keyboard backlight
        listener {
            timeout = 30
            on-timeout = brightnessctl -sd tpacpi::kbd_backlight set 0
            on-resume = brightnessctl -rd tpacpi::kbd_backlight
            ignore_inhibit = true
        }

        # Screen dim
        listener {
            timeout = 60
            on-timeout = brightnessctl -s set 10
            on-resume = brightnessctl -r
        }

        # Screen off
        listener {
            timeout = 120
            on-timeout = hyprctl dispatch dpms off
            on-resume = hyprctl dispatch dpms on
        }

        # Lock
        listener {
            timeout = 300
            on-timeout = loginctl lock-session
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
