{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.environment.hyprland {
    programs.regreet.enable = true;
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      # systemd.setPath.enable = true;
    };

    # Additional services/programs
    programs.waybar.enable = true;
    programs.hyprlock.enable = true;
    services.hypridle.enable = true;
    services.elephant.enable = true;

    # Fix apps not starting
    systemd.user.services.waybar.path = [ "/run/current-system/sw" ];
    systemd.user.services.elephant.path = [ "/run/current-system/sw" ];

    environment.systemPackages = with pkgs; [
      nwg-dock-hyprland
      nwg-drawer
      walker

      impala
      bluetui
      playerctl
      brightnessctl

      nautilus
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

    home-manager.users.${config.user.name} = { config, ... }: {
      wayland.windowManager.hyprland = {
        systemd.enable = false;
      };

      xdg.configFile."hypr/hyprland.conf".source =
        config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config/hyprland.conf";

      xdg.configFile."hypr/hypridle.conf".source =
        config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config/hypridle.conf";

      xdg.configFile."waybar/config".source =
        config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config/waybar/config.jsonc";

      xdg.configFile."waybar/style.css".source =
        config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config/waybar/style.css";

      xdg.configFile."nwg-dock-hyprland/style.css".source =
        config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config/nwg-dock/style.css";

      home.file.".cache/nwg-dock-pinned".text = ''
        org.gnome.Nautilus
        firefox
        com.mitchellh.ghostty
        dev.zed.Zed
      '';

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
