{ config, inputs, ... }:
let
  palette = config.colorScheme.palette;
  convert = inputs.nix-colors.lib.conversions.hexToRGBString;
  backgroundRgb = "rgb(${convert ", " palette.base00})";
  foregroundRgb = "rgb(${convert ", " palette.base05})";
in
{
  xdg.configFile = {
    "waybar/style.css".text = ''
      @import "./theme.css";
      * {
        border: none;
        border-radius: 0;
        min-height: 0;
        font-family: JetBrains Mono Nerd Font;
        font-size: 14px;
        /* background-color: transparent; */
      }

      #workspaces {
        margin-left: 7px;
      }

      #workspaces button {
        all: initial;
        padding: 2px 6px;
        margin-right: 3px;
      }

      #custom-dropbox,
      #cpu,
      #power-profiles-daemon,
      #battery,
      #network,
      #bluetooth,
      #wireplumber,
      #tray,
      #clock {
        background-color: transparent;
        min-width: 12px;
        margin-right: 13px;
      }

      tooltip {
        padding: 2px;
      }

      tooltip label {
        padding: 2px;
      }
    '';

    "waybar/theme.css".text = ''
      @define-color background ${backgroundRgb};
      * {
        color: ${foregroundRgb}; 
      }

      window#waybar {
        background-color: ${backgroundRgb};
      }
    '';
  };

  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        spacing = 0;
        height = 26;
        modules-left = [
          "hyprland/workspaces"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "tray"
          "bluetooth"
          "network"
          "wireplumber"
          "cpu"
          "power-profiles-daemon"
          "battery"
        ];
        "hyprland/workspaces" = {
          on-click = "activate";
          format = "{icon}";
          format-icons = {
            default = "";
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            active = "󱓻";
          };
          persistent-workspaces = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
          };
        };
        cpu = {
          interval = 5;
          format = "󰍛";
          on-click = "ghostty -e btop";
        };
        clock = {
          format = "{:%A %I:%M %p}";
          format-alt = "{:%d %B W%V %Y}";
          tooltip = false;
        };
        network = {
          format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
          format = "{icon}";
          format-wifi = "{icon}";
          format-ethernet = "󰀂";
          format-disconnected = "󰖪";
          tooltip-format-wifi = "{essid} ({frequency} GHz)\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          tooltip-format-ethernet = "⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          tooltip-format-disconnected = "Disconnected";
          interval = 3;
          nospacing = 1;
          on-click = "ghostty -e nmcli";
        };
        battery = {
          interval = 5;
          format = "{capacity}% {icon}";
          format-discharging = "{icon}";
          format-charging = "{icon}";
          format-plugged = "";
          format-icons = {
            charging = [
              "󰢜"
              "󰂆"
              "󰂇"
              "󰂈"
              "󰢝"
              "󰂉"
              "󰢞"
              "󰂊"
              "󰂋"
              "󰂅"
            ];
            default = [
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
          };
          format-full = "Charged ";
          tooltip-format-discharging = "{power:>1.0f}W↓ {capacity}%";
          tooltip-format-charging = "{power:>1.0f}W↑ {capacity}%";
          states = {
            warning = 20;
            critical = 10;
          };
        };
        bluetooth = {
          format = "󰂯";
          format-disabled = "󰂲";
          format-connected = "";
          tooltip-format = "Devices connected: {num_connections}";
          on-click = "blueberry";
        };
        wireplumber = {
          "format" = "";
          format-muted = "󰝟";
          scroll-step = 5;
          on-click = "pavucontrol";
          tooltip-format = "Playing at {volume}%";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          max-volume = 100;
        };
        tray = { spacing = 13; };
        power-profiles-daemon = {
          format = "{icon}";
          tooltip-format = "Power profile: {profile}";
          tooltip = true;
          format-icons = {
            power-saver = "󰡳";
            balanced = "󰊚";
            performance = "󰡴";
          };
        };
      }
    ];
  };
}
