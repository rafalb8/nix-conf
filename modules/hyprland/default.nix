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

    programs.hyprland = { enable = true; withUWSM = true; };
    services.gvfs.enable = true;

    environment.systemPackages = with pkgs; [
      # Tools
      ddcutil

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

      dconf.enable = true;
      dconf.settings = {
        "org/gnome/desktop/wm/preferences".button-layout = ":";
        "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      };

      # Cursor
      home.pointerCursor = {
        enable = true;
        gtk.enable = true;
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
      };
    };
  };
}
