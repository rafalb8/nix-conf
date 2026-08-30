{ config, ... }:
{
  # Hide folders in home
  home.file.".hidden".text = ''
    Desktop
    Public
    Templates
    go
  '';

  xdg.enable = true;
  xdg.configFile = {
    # Enable Wayland HDR for Jellyfin MPV Shim and MPV
    "mpv/mpv.conf".text = ''target-colorspace-hint-mode=source'';
    "jellyfin-mpv-shim/mpv.conf".text = ''target-colorspace-hint-mode=source'';

    # Zed Config
    "zed".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config/zed";
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
}
