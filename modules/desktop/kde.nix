{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop.environment.kde;
in
{
  options.modules.desktop.environment.kde = {
    enable = lib.mkEnableOption "KDE desktop module";
  };

  config = lib.mkIf cfg.enable {
    # Enable the KDE Plasma.
    services = {
      desktopManager.plasma6.enable = true;
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        settings.Users.RememberLastSession = "false";
      };
    };

    # Additional packages
    # environment.systemPackages = with pkgs; [ mission-center ];

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
