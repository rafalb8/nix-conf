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
          "spacing": 0,
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
            "format": "{}",
            "separate-outputs": true,
            "rewrite": {
              "": "Desktop",
            },
          },

          "clock": {
            "format": "{:%a %d %b  %H:%M}",
            "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
          },

          "tray": {
            "spacing": 4,
            "icon-size": 16,
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
            background-color: rgba(0, 0, 0, 0);
        }

        * {
            min-height: 0;
            border: none;
            border-radius: 0;
            padding: 0;
            margin: 0;
            color: #ffffff;
            font-family: "JetBrainsMono Nerd Font", Roboto, Arial, sans-serif;
        }

        #workspaces,
        #window,
        #clock,
        #tray,
        #custom-notification,
        #pulseaudio,
        #bluetooth,
        #network,
        #battery {
            background: linear-gradient(
                180deg,
                rgba(255, 255, 255, 0.15) 0%,
                rgba(255, 255, 255, 0.05) 50%,
                rgba(255, 255, 255, 0.1) 100%
            );
            border-top: 1px solid rgba(255, 255, 255, 0.3);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            box-shadow:
                inset 0 1px 1px rgba(255, 255, 255, 0.1),
                0 1px 2px rgba(0, 0, 0, 0.2);

            margin-top: 3px;
            margin-bottom: 3px;
        }

        #workspaces,
        #window,
        #clock,
        #tray {
            margin-left: 4px;
            margin-right: 4px;
            padding: 0 10px;
            border-radius: 8px;
            border-left: 1px solid rgba(255, 255, 255, 0.15);
            border-right: 1px solid rgba(255, 255, 255, 0.15);
        }

        #custom-notification,
        #pulseaudio,
        #bluetooth,
        #battery {
            padding: 0 4px;
        }

        #network {
            padding-left: 4px;
            padding-right: 10px;
        }

        #custom-notification {
            border-radius: 8px 0 0 8px;
            border-left: 1px solid rgba(255, 255, 255, 0.15);
            margin-left: 6px;
        }

        #battery {
            border-radius: 0 8px 8px 0;
            border-right: 1px solid rgba(255, 255, 255, 0.15);
            margin-right: 6px;
        }

        #tray,
        #bluetooth {
            font-size: 16px;
        }

        #clock,
        #battery,
        #pulseaudio,
        #network,
        #custom-notification {
            font-size: 14px;
        }

        #workspaces button {
            font-size: 14px;
        }

        #window {
            font-size: 14px;
        }
      '';
    };
  };
}
