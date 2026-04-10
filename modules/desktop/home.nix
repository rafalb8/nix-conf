{ config, ... }:
{
  # Hide folders in home
  home.file.".hidden".text = ''
    Desktop
    Public
    Templates
    go
  '';

  # Enable Wayland HDR for Jellyfin MPV Shim and MPV
  xdg.enable = true;
  xdg.configFile = {
    "mpv/mpv.conf".text = ''vo=dmabuf-wayland'';
    "jellyfin-mpv-shim/mpv.conf".text = ''vo=dmabuf-wayland'';
  };

  # Easyeffects service
  services.easyeffects = {
    enable = true;
    presets = [ "Clean" "Normalize" "Dolby Headphones" ];
  };

  # Terminal
  programs.ghostty = {
    enable = true;
    systemd.enable = true;
    enableZshIntegration = false;
    settings = {
      window-width = 120;
      window-height = 30;
      background-opacity = 0.8;
    };
  };

  # Zed Config
  home.file.".config/zed".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config/zed";
}
