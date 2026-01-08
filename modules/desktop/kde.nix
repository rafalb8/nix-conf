{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.environment.kde {
    # Enable the KDE Plasma.
    services = {
      desktopManager.plasma6.enable = true;
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };
    };

    # Add essentials
    # environment.systemPackages = with pkgs; [
    #   # mission-center
    # ];

    # Exclude KDE default packages
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
      khelpcenter
      ktexteditor
      konsole
      okular
      elisa
      kate
    ];
  };
}
