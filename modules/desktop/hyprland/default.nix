{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop;
in
{
  imports = [
    ./dock.nix
    ./hypridle.nix
    ./hyprland.nix
    ./scripts.nix
    ./waybar.nix
  ];

  config = lib.mkIf cfg.environment.hyprland {
    programs.regreet.enable = true;
    programs.hyprlock.enable = true;
    services.elephant.enable = true;
    systemd.user.services.elephant.path = [ "/run/current-system/sw" ];

    environment.systemPackages = with pkgs; [
      swaynotificationcenter
      libnotify
      hyprpaper
      hyprshot
      walker

      impala
      bluetui
      playerctl
      brightnessctl

      nautilus
      loupe
    ];

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    # Set dark mode in Qt applications
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };

    home-manager.users.${config.user.name} = {
      # Dark mode
      # Set dark mode in GTK applications
      gtk = {
        enable = true;
        theme = {
          name = "Adwaita-dark";
          package = pkgs.gnome-themes-extra;
        };

        iconTheme = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
        };

        font = {
          name = "Sans";
          size = 11;
        };

        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };

        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
      };

      dconf.enable = true;
      dconf.settings = {
        "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      };

      # Cursor
      home.pointerCursor = {
        gtk.enable = true;
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
      };
    };
  };
}
