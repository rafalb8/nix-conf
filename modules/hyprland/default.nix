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
    services.displayManager = {
      gdm.enable = true;
      defaultSession = "hyprland-uwsm";
    };

    # Fix gdm
    systemd.services.display-manager.path = [ pkgs.uwsm ];
    environment.sessionVariables.XDG_DATA_DIRS = [ "${pkgs.gdm}/share" ];
    ## Issue: https://github.com/NixOS/nixpkgs/issues/523332
    ## PR: https://github.com/NixOS/nixpkgs/pull/523948
    security.pam.services.gdm-launch-environment.rules.session.env-greeter = {
      control = "required";
      order = config.security.pam.services.gdm-launch-environment.rules.session.env.order + 50;
      modulePath = "${config.security.pam.package}/lib/security/pam_env.so";
      settings.conffile =
        let
          env = config.services.displayManager.generic.environment;
        in
        pkgs.writeText "gdm-launch-environment-env-conf"
          ''
            PATH                    DEFAULT="''${PATH}:${pkgs.gnome-session}/bin"
            XDG_DATA_DIRS           DEFAULT="''${XDG_DATA_DIRS}:${env.XDG_DATA_DIRS}"
            GDM_X_SERVER_EXTRA_ARGS DEFAULT="${env.GDM_X_SERVER_EXTRA_ARGS}"
          '';
      settings.readenv = 0;
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
      "/share/hypr" # lua stub: /run/current-system/sw/share/hypr/stubs
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
      xdg.configFile."hypr/custom.lua".text = cfg.custom;
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

      gtk = {
        enable = true;
        font.name = "Sans";
        theme.name = "Adwaita-dark";
        gtk4.theme.name = "Adwaita";
        gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
      };

      dconf.enable = true;
      dconf.settings = {
        "org/gnome/desktop/interface".color-scheme = "prefer-dark";
        "org/gnome/desktop/wm/preferences".button-layout = ":";
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
