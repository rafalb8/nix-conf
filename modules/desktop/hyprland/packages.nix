{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.environment.hyprland {

    environment.systemPackages = with pkgs; [
      # Hyprland essentials
      pamixer
      hyprshot
      playerctl
      hyprpicker
      hyprsunset
      pavucontrol
      brightnessctl
      gnome-themes-extra

      # System essentials
      nautilus
      libnotify
      blueberry
      mission-center
      gnome-calculator

      # Other
      ghex
    ];
  };
}
