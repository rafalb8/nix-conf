{ config, inputs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.environment.hyprland {
    home-manager.users.${config.user.name} = { config, lib, ... }: {
      imports = [
        (import ./hyprlock.nix { inherit config inputs; })
        ./mako.nix
        (import ./waybar.nix { inherit config inputs; })
        ./wofi.nix
      ];

      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
          };
          listener = [
            {
              timeout = 300;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 330;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
            }
          ];
        };
      };

      services.hyprpaper = {
        enable = true;
        settings = {
          preload = [
            "~/Pictures/Wallpapers/Mountain Light.jpg"
          ];
          wallpaper = [
            ",~/Pictures/Wallpapers/Mountain Light.jpg"
          ];
        };
      };

      services.hyprpolkitagent.enable = true;
    };
  };
}
