{ config, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.environment.hyprland {
    home-manager.users.${config.user.name} = { config, lib, ... }: {
      programs.waybar = {
        enable = true;
        # systemd.enable = true;

        settings.mainBar = {
          layer = "top";
          position = "top";
          height = 28;
          spacing = 5;

          modules-left = [
            "custom/launcher"
            "hyprland/workspaces"
            "hyprland/window"
          ];

          modules-center = [
            "clock"
          ];

          modules-right = [
            "tray"
            "pulseaudio"
            "network"
            "battery"
            "custom/power"
          ];

          "custom/launcher" = {
            format = "NixOS";
            tooltip = false;
            on-click = "rofi -show drun";
          };

          "hyprland/workspaces" = {
            format = "{name}";
            tooltip = true;
            format-tooltip = "{name}";
            on-click = "activate";
          };

          "hyprland/window" = {
            format = "{}";
            max-length = 50;
            tooltip = true;
          };

          clock = {
            format = "{:%a %b %d %H:%M}";
            format-alt = "{:%A, %B %d, %Y}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };

          pulseaudio = {
            format = "{icon}\t{volume}%";
            format-muted = "\tMuted";
            format-icons = {
              default = [ "" "" ];
            };
            on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          };

          network = {
            format-wifi = " {essid}";
            format-ethernet = " Eth";
            format-disconnected = " Disconnected";
            tooltip-format = "{ifname} via {gwaddr} ";
            on-click = "nm-connection-editor";
          };

          battery = {
            states = {
              good = 90;
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = "充電 {capacity}%";
            format-plugged = " {capacity}%";
            format-alt = "{time}";
            format-icons = [ "" "" "" "" "" ];
          };

          tray = {
            icon-size = 16;
            spacing = 10;
          };

          "custom/power" = {
            format = "";
            tooltip = false;
            on-click = "wlogout"; # Ensure wlogout is installed
          };
        };

        style = ''
          /* General Waybar styling */
          #waybar {
              background-color: rgba(0, 0, 0, 0.4); /* Semi-transparent dark background */
              border-bottom: none; /* No border at the bottom */
              font-family: Noto Sans, system-ui, sans-serif;
              font-size: 13px; /* Slightly smaller font for a sleek look */
              color: #ffffff; /* White text */
              padding: 0 10px; /* Padding on the left/right edges */
              box-shadow: none; /* No shadow by default */
          }

          #waybar .module {
              padding: 0 8px; /* Padding around individual modules */
              border-radius: 5px; /* Subtle rounded corners */
              margin: 0 2px; /* Small margin between modules */
          }

          /* Hover effects for modules */
          #waybar .module:hover {
              background-color: rgba(255, 255, 255, 0.1); /* Light highlight on hover */
              transition: background-color 0.2s ease-in-out;
          }

          #custom-launcher {
              padding-left: 0; /* No left padding for the first module */
              padding-right: 8px;
              font-size: 16px; /* Slightly larger icon */
          }

          #hyprland-workspaces button {
              /* Styles for individual workspace buttons */
              padding: 0 5px;
              color: #ffffff;
              background-color: transparent;
              border: none;
              border-radius: 5px;
          }

          #hyprland-workspaces button.active {
              /* Style for the active workspace */
              background-color: rgba(255, 255, 255, 0.15); /* Slightly brighter for active */
              border-bottom: none;
          }

          #hyprland-workspaces button:hover {
              background-color: rgba(255, 255, 255, 0.1);
          }

          #hyprland-window {
              /* Style for the window title */
              font-weight: bold;
              padding-left: 10px;
              padding-right: 10px;
          }

          #clock {
              /* Centered clock */
              font-weight: normal;
              padding-left: 15px;
              padding-right: 15px;
          }

          #pulseaudio,
          #network,
          #battery,
          #custom-power,
          #tray {
              /* Common styling for system icons */
              padding: 0 8px;
          }

          /* Tray icons can sometimes look a bit off, try to style them */
          #tray {
              padding-left: 10px;
              padding-right: 5px;
          }

          /* Icon colors for better visibility */
          #pulseaudio { color: #8BE9FD; } /* Light blue */
          #network { color: #50FA7B; }    /* Green */
          #battery.charging { color: #50FA7B; }
          #battery.good { color: #50FA7B; }
          #battery.warning { color: #FFB86C; } /* Orange */
          #battery.critical { color: #FF5555; } /* Red */
          #custom-power { color: #FF6E6E; } /* Reddish for power icon */

          /* Tooltip styling (for information popups) */
          tooltip {
              background-color: rgba(0, 0, 0, 0.8);
              color: #ffffff;
              border-radius: 5px;
              padding: 5px 10px;
              font-size: 12px;
          }
        '';
      };
    };
  };
}
