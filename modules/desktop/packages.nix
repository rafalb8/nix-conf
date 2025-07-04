{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.enable {
    # Add reminder for jellyfin
    warnings =
      lib.optional (pkgs.jellyfin-media-player.version > "1.12.0")
        "Desktop entry may be fixed https://github.com/jellyfin/jellyfin-media-player/issues/649";

    environment.systemPackages = with pkgs; [
      # Terminal
      alacritty

      # Media
      jellyfin-media-player
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
      vscode

      # Tools
      imagemagick_light
      impression
      obsidian
      anydesk
      szyszka

      # Web
      qbittorrent
      discord
    ];

    # FastFlix
    programs.fastflix.enable = true;
  };
}
