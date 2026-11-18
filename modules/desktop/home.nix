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
      font-family = "IoskeleyMonoTerm Nerd Font Mono";
    };
  };
}
