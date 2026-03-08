{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop.environment.hyprland;
in
{
  imports = [
    ./dock.nix
    ./hypridle.nix
    ./scripts.nix
    ./waybar.nix
  ];

  options.modules.desktop.environment.hyprland = {
    enable = lib.mkEnableOption "Hyprland desktop module";

    custom = lib.mkOption {
      type = lib.types.str;
      description = "custom hyprland settings";
    };

    wallpaper = lib.mkOption {
      type = lib.types.str;
      description = "set hyprpaper wallpaper";
    };
  };

  config = lib.mkIf cfg.enable {
    # Display Manager
    programs.regreet = {
      enable = true;
      settings.GTK.application_prefer_dark_theme = true;
    };

    # Compositor
    programs.hyprland = { enable = true; withUWSM = true; };

    # Components
    services.gvfs.enable = true;
    programs.hyprlock.enable = true;
    environment.systemPackages = with pkgs; [
      swaynotificationcenter
      libnotify
      hyprpaper
      elephant
      walker

      # TUI/CLI tools
      impala
      bluetui
      playerctl
      brightnessctl

      # Basic apps
      loupe
      nautilus
      pavucontrol
    ];

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1"; # Run apps without Xwayland
    };

    # Allow sharing wifi connection
    security.wrappers.impala = {
      setuid = true;
      owner = "root";
      group = "root";
      source = "${pkgs.impala}/bin/impala";
    };

    # Set dark mode in Qt applications
    qt = {
      enable = true;
      style = "adwaita-dark";
      platformTheme = "gnome";
    };

    home-manager.users.${config.user.name} = {
      xdg.configFile."hypr/custom.conf".text = cfg.custom;
      xdg.configFile."hypr" = {
        source = ../../../config/hypr;
        recursive = true;
      };
      xdg.configFile."hypr/hyprpaper.conf".text = ''
        wallpaper {
            monitor =
            path = ${cfg.wallpaper}
            fit_mode = cover
        }
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
