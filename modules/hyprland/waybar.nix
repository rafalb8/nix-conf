{ config, lib, pkgs, ... }:
let
  cfg = config.modules.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ waybar ];
    home-manager.users."rafalb8" = {
      xdg.configFile."waybar/config".text = ''
        {
          "layer": "top",
          "position": "top",
          "height": 32,
          "spacing": 0,
          "output": ["DP-1", "eDP-1"],
          "modules-left": ["hyprland/workspaces", "hyprland/window"],
          "modules-center":["clock"],
          "modules-right":[
            "tray",
            "group/system"
          ],

          "hyprland/workspaces": {
            "format": "{id}",
            "active-only": true
          },

          "hyprland/window": {
            "format": "{}",
            "separate-outputs": true,
            "rewrite": {
              "": "Desktop"
            }
          },

          "clock": {
            "format": "{:%a %d %b  %H:%M}",
            "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
          },

          "tray": {
            "spacing": 4,
            "icon-size": 16
          },

          "group/system": {
            "orientation": "horizontal",
            "modules":[
              "custom/notification",
              "pulseaudio",
              "pulseaudio#source",
              "bluetooth",
              "network#wifi",
              "network#ethernet",
              "battery"
            ]
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
              "dnd-inhibited-none": ""
            },
            "return-type": "json",
            "exec-if": "which swaync-client",
            "exec": "swaync-client -swb",
            "on-click": "swaync-client -t -sw",
            "on-click-right": "swaync-client -d -sw",
            "escape": true
          },

          "pulseaudio": {
            "format": "{icon} {volume}%",
            "format-muted": "󰝟",
            "format-icons": {
              "default":["", "", ""]
            },
            "on-click": "/run/current-system/sw/bin/audioswitch"
          },

          "pulseaudio#source": {
            "format": "{format_source}",
            "format-source": "",
            "format-source-muted": "",
            "on-click": "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          },

          "bluetooth": {
            "format": "{icon}",
            "format-icons": {
              "enabled": "󰂱",
              "connected": "󰂱",
              "disconnected": "󰂲"
            },
            "on-click": "ghostty --class=waybar.popup --confirm-close-surface=false -e bluetui"
          },

          "network#wifi": {
              "interface": "wlan*",
              "format-wifi": " ",
              "format-disconnected": "",
              "tooltip-format": "{essid}: {ipaddr}",
              "on-click": "ghostty --class=waybar.popup --confirm-close-surface=false -e impala"
          },

          "network#ethernet": {
              "interface": "enp*",
              "format-ethernet": "󰈀 ",
              "format-disconnected": "",
              "tooltip-format": "{ifname}: {ipaddr}"
          },

          "battery": {
            "states": { "warning": 30, "critical": 15 },
            "format": "{icon} {capacity}%",
            "format-icons": ["", "", "", "", ""]
          }
        }
      '';

      xdg.configFile."waybar/style.css".text = ''
        * {
            min-height: 0;
            margin: 0;
            padding: 0;
            border: none;
            border-radius: 0;
            color: #ffffff;
            font-family: "JetBrainsMono Nerd Font", Roboto, Arial, sans-serif;
            font-size: 14px;
        }

        window#waybar {
            background-color: transparent;
        }

        /*
          Main glassmorphism blocks + the system pill container
        */
        #workspaces,
        #window,
        #clock,
        #tray,
        #system {
            margin: 3px 4px;
            background: linear-gradient(
                180deg,
                rgba(255, 255, 255, 0.15) 0%,
                rgba(255, 255, 255, 0.05) 50%,
                rgba(255, 255, 255, 0.1) 100%
            );
            border-top: 1px solid rgba(255, 255, 255, 0.3);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            border-left: 1px solid rgba(255, 255, 255, 0.15);
            border-right: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 8px;
            box-shadow:
                inset 0 1px 1px rgba(255, 255, 255, 0.1),
                0 1px 2px rgba(0, 0, 0, 0.2);
        }

        /* Inner padding for the standalone modules */
        #workspaces,
        #window,
        #clock,
        #tray {
            padding: 0 10px;
        }

        /* The System Pill container's outer padding */
        #system {
            margin-left: 6px;
            margin-right: 6px;
            padding: 0 4px;
        }

        /*
          Perfectly symmetrical inner spacing for all icons inside the pill.
        */
        #custom-notification,
        #pulseaudio,
        #pulseaudio-source,
        #bluetooth,
        #network-wifi,
        #network-ethernet,
        #battery {
            padding: 0 6px;
        }

        #tray,
        #bluetooth {
            font-size: 16px;
        }

        #workspaces button {
            font-size: inherit;
        }
      '';
    };
  };
}
