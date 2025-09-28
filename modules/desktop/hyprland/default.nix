{ config, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  imports = [
    ./hypr
    ./services
    ./packages.nix
  ];

  config = lib.mkIf cfg.environment.hyprland {
    services = {
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
      gvfs.enable = true;
    };

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    # Fix nautilus shortcut
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "alacritty";
    };

    # Fonts
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrains Mono Nerd Font" ];
      };
    };

  };
}
