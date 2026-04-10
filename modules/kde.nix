{ config, pkgs, lib, ... }:
let
  cfg = config.modules.kde;
in
{
  options.modules.kde = {
    enable = lib.mkEnableOption "Enable KDE";
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
