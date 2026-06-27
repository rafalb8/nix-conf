{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop;

  jellyfin-desktop = pkgs.symlinkJoin {
    name = "jellyfin-desktop-${pkgs.jellyfin-desktop.version}";
    paths = [ pkgs.jellyfin-desktop ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/jellyfin-desktop \
        --set QTWEBENGINE_FORCE_USE_GBM 0
    '';
  };
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Media
      jellyfin-desktop
      kdePackages.kdenlive
      stable.jellyfin-mpv-shim
      pear-desktop
      obs-studio
      audacity
      krita
      mpv

      # Development
      temurin-jre-bin
      android-tools
      zed-editor
      opencode
      ghostty
      imhex

      # Tools
      onlyoffice-desktopeditors
      imagemagick
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
