{ config, inputs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.environment.hyprland {
    home-manager.users.${config.user.name} = { config, lib, ... }: {
      imports = [
        ./autostart.nix
        ./binds.nix
        ./envs.nix
        ./input.nix
        ./layout.nix
        ./windows.nix
      ];

      # Enable wayland configuration
      wayland.windowManager.hyprland.enable = true;

      # Monitor
      wayland.windowManager.hyprland.settings.monitor = [
        # output, resolution, position, scale, args ...
        "DP-1, highrr, 0x0, 1, cm, auto, vrr, 3"
        ", preferred, auto, auto"
      ];

      colorScheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;

      dconf.enable = true;
      dconf.settings = {
        "org/gnome/desktop/interface".color-scheme = "prefer-dark"; # Dark mode
      };
    };
  };
}
