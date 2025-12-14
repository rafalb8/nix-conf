{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.enable {
    # Reminders
    warnings = lib.optional (pkgs.jellyfin-media-player.version > "1.12.0")
      ''
        Desktop entry may be fixed https://github.com/jellyfin/jellyfin-media-player/issues/649"
        Also upgraded qtwebengine?
      '';

    # Insecure exceptions
    nixpkgs.config.permittedInsecurePackages =
      lib.optional (pkgs.jellyfin-media-player.version == "1.12.0") "qtwebengine-5.15.19";

    environment.systemPackages = with pkgs; [
      # Media
      stable.jellyfin-media-player
      kdePackages.kdenlive
      jellyfin-mpv-shim
      youtube-music
      obs-studio
      audacity
      calibre
      gimp
      mpv

      # Development
      temurin-jre-bin
      android-tools
      zed-editor
      vscode
      imhex

      # Tools
      imagemagick_light
      impression # USB writer
      alacritty
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
