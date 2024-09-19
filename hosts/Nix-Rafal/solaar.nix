{ config, pkgs, ... }:
{
  # Add solaar
  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  home-manager.users.${config.user.name} = {
    xdg = {
      enable = true;

      # Add config
      configFile."solaar" = {
        source = ../../dotfiles/solaar;
        recursive = true;
      };

      # Custom desktop entry
      desktopEntries = {
        solaar = {
          name = "Solaar";
          icon = "solaar";
          exec = "solaar -w hide";
          categories = [ "Utility" "GTK" ];
        };
      };
    };

    autostart = {
      enable = true;
      packages = [ pkgs.solaar ];
    };
  };
}
