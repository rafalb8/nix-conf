{ config, lib, inputs, ... }:
let
  cfg = config.modules.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    programs.noctalia.enable = true;
    home-manager.users."rafalb8" = {
      imports = [ inputs.noctalia.homeModules.default ];

      programs.noctalia.enable = true;
      programs.noctalia.settings = {
        location.auto_locate = true;

        brightness = {
          enable_ddcutil = true;
          sync_all_monitors = true;
        };

        theme = {
          mode = "dark";
          source = "community";
          builtin = "Ayu";
          community_palette = "Ayu Blue";
          templates = [ "gtk3" "gtk4" "ghostty" "qt" ];
        };

        wallpaper = {
          enabled = true;
          default.path = cfg.wallpaper;
        };

        shell = {
          button_borders = false;
          card_borders = false;
          font_family = "Noto Sans";
          input_borders = false;
          polkit_agent = true;
          popup_borders = false;
          animation.speed = 1.25;
          screenshot.directory = "~/Pictures/Screenshots";
        };

        shell.panel = {
          borders = false;
          open_near_click_control_center = true;
          transparency_mode = "glass";
          session_placement = "floating";
          session_position = "center";
        };

        shell.session.actions = [
          {
            action = "logout";
            enabled = true;
            shortcut = "1";
          }
          {
            action = "lock_and_suspend";
            enabled = true;
            shortcut = "2";
          }
          {
            action = "reboot";
            enabled = true;
            shortcut = "3";
          }
          {
            action = "shutdown";
            enabled = true;
            shortcut = "4";
          }
        ];

        idle = {
          behavior_order = [ "screen-off" "lock" "lock-and-suspend" ];

          behavior.screen-off = {
            action = "screen_off";
            enabled = true;
            timeout = 120.0;
          };

          behavior.lock = {
            action = "lock";
            enabled = true;
            timeout = 300.0;
          };

          behavior.lock-and-suspend = {
            action = "lock_and_suspend";
            enabled = true;
            timeout = 1800.0;
          };
        };

        bar.default = {
          capsule = true;
          background_opacity = 0.5;
          concave_edge_corners = false;
          thickness = 32;
          margin_ends = 0;
          radius = 0;
          start = [ "launcher" "workspaces" "active_window" ];
          end = [
            "media"
            "tray"
            "notifications"
            "clipboard"
            "network"
            "bluetooth"
            "volume"
            "brightness"
            "battery"
            "control-center"
          ];
        };

        widget.active_window.min_length = 0;
        widget.active_window.max_length = 500;
        widget.media.hide_when_no_media = true;
      };
    };

  };
}
