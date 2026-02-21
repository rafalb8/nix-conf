{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.environment.hyprland {
    environment.systemPackages = with pkgs; [ waybar ];
    home-manager.users.${config.user.name} = {
      xdg.configFile."waybar/config".text = ''
        {
          "layer": "top",
          "position": "top",
          "height": 32,
          "spacing": 4,
          "modules-left": ["hyprland/window"],
          "modules-center": ["clock"],
          "modules-right": [
            "tray",
            "custom/notification",
            "pulseaudio",
            "bluetooth",
            "network",
            "battery",
          ],

          "hyprland/window": {
            "format": "  <b>{}</b>",
            "rewrite": {
              "": "Desktop",
            },
            "separate-outputs": true,
          },

          "clock": {
            "format": "{:%a %d %b  %H:%M}",
            "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
          },

          "tray": {
            "spacing": 4,
            "icon-size": 16,
            "icon-theme": "Adwaita",
          },

          "custom/notification": {
            "tooltip": false,
            "format": "{icon}",
            "format-icons": {
              "notification": "<span foreground='red'><sup></sup></span>",
              "none": "",
              "dnd-notification": "<span foreground='red'><sup></sup></span>",
              "dnd-none": "",
              "inhibited-notification": "<span foreground='red'><sup></sup></span>",
              "inhibited-none": "",
              "dnd-inhibited-notification": "<span foreground='red'><sup></sup></span>",
              "dnd-inhibited-none": "",
            },
            "return-type": "json",
            "exec-if": "which swaync-client",
            "exec": "swaync-client -swb",
            "on-click": "swaync-client -t -sw",
            "on-click-right": "swaync-client -d -sw",
            "escape": true,
          },

          "pulseaudio": {
            "format": "{icon} {volume}% {format_source}",
            "format-muted": "󰝟 {format_source}",
            "format-source": "",
            "format-source-muted": "",
            "format-icons": {
              "default": ["", "", ""],
            },
            "on-click": "/run/current-system/sw/bin/audioswitch",
          },

          "bluetooth": {
            "format": "{icon}",
            "format-icons": {
              "enabled": "󰂱",
              "connected": "󰂱",
              "disconnected": "󰂲",
            },
            "on-click": "ghostty --class=waybar.popup --confirm-close-surface=false -e bluetui",
          },

          "network": {
            "format-wifi": "",
            "format-ethernet": "󰈀 {ifname}",
            "on-click": "ghostty --class=waybar.popup --confirm-close-surface=false -e impala",
          },

          "battery": {
            "states": { "warning": 30, "critical": 15 },
            "format": "{icon} {capacity}%",
            "format-icons": ["", "", "", "", ""],
          },
        }
      '';

      xdg.configFile."waybar/style.css".text = ''
        * {
            border: none;
            border-radius: 0;
            font-family: "JetBrainsMono Nerd Font", Roboto, Arial, sans-serif;
            font-size: 14px;
            min-height: 0;
        }

        .modules-right {
            margin-right: 8px;
        }

        #custom-notification,
        #pulseaudio,
        #battery {
            font-size: 16px;
            padding: 0 4px;
            color: #ffffff;
        }

        #bluetooth {
            font-size: 18px;
            padding: 0 4px;
            color: #ffffff;
        }

        #network,
        #tray,
        #clock {
            padding: 0 8px;
            color: #ffffff;
        }

        #window {
            padding: 0 8px;
            color: #ffffff;
        }

        #custom-notification {
            margin-right: 2px;
        }
      '';
    };
  };
}
