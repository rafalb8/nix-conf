{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.enable {
    # Reminders
    # warnings = lib.optional (pkgs.jellyfin-media-player.version > "1.12.0") '''';

    # Insecure exceptions
    # nixpkgs.config.permittedInsecurePackages =
    #   lib.optional (pkgs.jellyfin-media-player.version == "1.12.0") "qtwebengine-5.15.19";

    environment.systemPackages = with pkgs; [
      # Media
      jellyfin-desktop
      stable.kdePackages.kdenlive
      jellyfin-mpv-shim
      pear-desktop
      obs-studio
      audacity
      calibre
      gimp
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
      qbittorrent
      discord
    ];

    # FastFlix
    programs.fastflix.enable = true;

    # Autostart
    autostart = {
      enable = true;
      packages = [ pkgs.discord ];
    };
  };
}
