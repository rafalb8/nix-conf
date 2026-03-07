{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop.environment.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ waybar ];
    home-manager.users.${config.user.name} = {
      xdg.configFile."waybar/config".text = ''
        {
          "layer": "top",
          "position": "top",
          "height": 32,
          "spacing": 4,
          "modules-left": ["hyprland/workspaces", "hyprland/window"],
          "modules-center": ["clock"],
          "modules-right": [
            "tray",
            "custom/notification",
            "pulseaudio",
            "bluetooth",
            "network#wifi",
            "network#ethernet",
            "battery",
          ],

          "hyprland/workspaces": {
            "format": "{id}",
            "active-only": true,
          },

          "hyprland/window": {
            "format": "<b>{}</b>",
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
            "format": "{icon} {volume}%",
            "format-muted": "󰝟",
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

          "network#wifi": {
              "interface": "wlan*",
              "format-wifi": "",
              "format-disconnected": "",
              "tooltip-format": "{essid}: {ipaddr}",
              "on-click": "ghostty --class=waybar.popup --confirm-close-surface=false -e impala"
          },

          "network#ethernet": {
              "interface": "enp*",
              "format-ethernet": "󰈀",
              "format-disconnected": "",
              "tooltip-format": "{ifname}: {ipaddr}",
          },

          "battery": {
            "states": { "warning": 30, "critical": 15 },
            "format": "{icon} {capacity}%",
            "format-icons": ["", "", "", "", ""],
          },
        }
      '';

      xdg.configFile."waybar/style.css".text = ''
        window#waybar {
            background-color: #000000;
            transition-duration: 0.5s;
            transition-property: background-color;
        }

        /* Base styles for all modules */
        * {
            min-height: 0;
            border: none;
            border-radius: 0;
            color: #ffffff;
            font-size: 14px;
            font-family: "JetBrainsMono Nerd Font", Roboto, Arial, sans-serif;
        }

        #workspaces {
            margin: 4px 4px;
            padding: 0 6px;
            border-radius: 8px;

            background: linear-gradient(
                180deg,
                rgba(255, 255, 255, 0.2) 0%,
                rgba(255, 255, 255, 0.05) 50%,
                rgba(255, 255, 255, 0.1) 100%
            );

            border: 1px solid rgba(255, 255, 255, 0.2);
            border-top: 1px solid rgba(255, 255, 255, 0.5);

            box-shadow:
                inset 0 1px 1px rgba(255, 255, 255, 0.3),
                inset 0 -2px 4px rgba(0, 0, 0, 0.4),
                0 2px 4px rgba(0, 0, 0, 0.5);

            transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1);
        }

        #workspaces button {
            background: transparent;
            padding: 0;
        }

        #workspaces button.active label {
            color: #ffffff;
            text-shadow: 0 0 8px rgba(255, 255, 255, 0.6);
            font-weight: 900;
        }

        /* Font Size */
        #tray,
        #bluetooth {
            font-size: 18px;
        }

        #battery,
        #pulseaudio,
        #network.wifi,
        #network.ethernet,
        #custom-notification {
            font-size: 16px;
        }

        /* Margins */
        #pulseaudio,
        #custom-notification {
            margin: 2px;
        }

        #network.wifi,
        #network.ethernet {
            margin-right: 8px;
        }
      '';
    };
  };
}
