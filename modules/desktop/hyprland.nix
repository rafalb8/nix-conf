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
    };
    services.hypridle.enable = true;
    programs.hyprlock.enable = true;
    programs.waybar.enable = true;

    environment.systemPackages = with pkgs; [
      nwg-dock-hyprland
      nwg-drawer
      nautilus
      anyrun
      playerctl
      brightnessctl
    ];
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    home-manager.users.${config.user.name} = { config, ... }: {
      dconf.enable = true;
      wayland.windowManager.hyprland = {
        systemd.enable = false;
      };

      xdg.configFile."hypr/hyprland.conf".source =
        config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config/hyprland.conf";

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
      gtk.enable = true;
      gtk.theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };

      gtk.gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk.gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };

      qt = {
        enable = true;
        platformTheme.name = "gtk";
        style.name = "adwaita-dark";
      };

      dconf.settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };

      # Cursor
      gtk.cursorTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
        size = 24;
      };
    };
  };
}
