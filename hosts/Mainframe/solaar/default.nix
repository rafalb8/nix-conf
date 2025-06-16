{ config, pkgs, ... }:
{
  # Add solaar
  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  # Allow Solaar to support certain features on non X11 systems
  environment.systemPackages = [ pkgs.gnomeExtensions.solaar-extension ];

  home-manager.users.${config.user.name} = {
    # Enable solaar extension
    dconf.enable = true;
    dconf.settings."org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [ "solaar-extension@sidevesh" ];
    };

    # Custom desktop entry
    xdg.enable = true;
    xdg.desktopEntries = {
      solaar = {
        name = "Solaar";
        icon = "solaar";
        exec = "solaar -w hide";
        categories = [ "Utility" "GTK" ];
      };
    };

    autostart = {
      enable = true;
      packages = [ pkgs.solaar ];
    };
  };
}
