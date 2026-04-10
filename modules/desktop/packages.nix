{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Media
      jellyfin-desktop
      stable.kdePackages.kdenlive
      jellyfin-mpv-shim
      pear-desktop
      obs-studio
      audacity
      krita
      mpv

      # Development
      temurin-jre-bin
      android-tools
      zed-editor
      ghostty
      vscode
      imhex
      lazygit
      opencode

      # Tools
      onlyoffice-desktopeditors
      imagemagick_light
      impression # USB writer
      obsidian
      deskflow
      szyszka # Bulk rename

      # Web
      signal-desktop
      qbittorrent
      discord
    ];

    # Autostart
    autostart = {
      enable = true;
      packages = [ pkgs.discord ];
    };
  };
}
