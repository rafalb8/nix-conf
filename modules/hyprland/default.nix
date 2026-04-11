{ config, lib, pkgs, paths, ... }:
let
  cfg = config.modules.hyprland;
in
{
  imports = lib.custom.importAll ./.;

  options.modules.hyprland = {
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
      sway-audio-idle-inhibit
      swaynotificationcenter
      libnotify
      hyprpaper
      hyprshot
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
      gnome-frog
      file-roller
      gnome-firmware
      gnome-calculator
      gnome-disk-utility
    ];

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1"; # Run electron apps without Xwayland
      NAUTILUS_4_EXTENSION_DIR = "${pkgs.nautilus-python}/lib/nautilus/extensions-4";
    };

    environment.pathsToLink = [
      "/share/nautilus-python/extensions"
    ];

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

    home-manager.users."rafalb8" = {
      xdg.configFile."hypr/custom.conf".text = cfg.custom;
      xdg.configFile."hypr" = {
        source = paths.hypr;
        recursive = true;
      };
      xdg.configFile."hypr/hyprpaper.conf".text = ''
        wallpaper {
            monitor =
            path = ${cfg.wallpaper}
            fit_mode = cover
        }
      '';

      gtk =
        let
          theme = { name = "Adwaita-dark"; package = pkgs.gnome-themes-extra; };
          extraConfig = { gtk-application-prefer-dark-theme = 1; };
        in
        {
          enable = true;
          inherit theme;
          gtk3 = { inherit theme extraConfig; };
          gtk4 = { inherit theme extraConfig; };
          iconTheme = { name = "Adwaita"; package = pkgs.adwaita-icon-theme; };
          font = { name = "Sans"; size = 11; };
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
