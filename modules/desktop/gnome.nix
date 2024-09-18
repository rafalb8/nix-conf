{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.environment.gnome {
    # Enable the GNOME Desktop Environment.
    services = {
      xserver = {
        enable = true;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };
      gvfs.enable = true;
    };

    # Add Gnome packages
    environment.systemPackages =
      # Gnome Extensions
      (with pkgs.gnomeExtensions; [
        arcmenu
        caffeine
        gsconnect
        appindicator
        dash-to-panel
        tiling-assistant
        quick-settings-audio-devices-hider
      ])
      ++
      # Essentials
      (with pkgs; [
        # gnome.gnome-terminal
        gnome.adwaita-icon-theme
        gnome.gnome-tweaks
        gnome.ghex
        mission-center
        adw-gtk3
      ]);

    home-manager.users.${config.user.name} = {
      dconf = {
        enable = true;
        settings = {
          # Dark mode
          "org/gnome/desktop/interface".color-scheme = "prefer-dark";

          # Shortcuts
          "org/gnome/desktop/wm/keybindings" = {
            close = [ "<Super>w" ];
            switch-applications = [ "<Super>Tab" ];
            switch-applications-backward = [ "<Shift><Super>Tab" ];
            switch-windows = [ "<Alt>Tab" ];
            switch-windows-backward = [ "<Shift><Alt>Tab" ];
          };
          "org/gnome/mutter/wayland/keybindings" = {
            restore-shortcuts = [ ];
          };

          # Custom
          "org/gnome/settings-daemon/plugins/media-keys" = {
            custom-keybindings = [
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
            ];
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
            name = "Terminal";
            command = "alacritty";
            binding = "<Super>t";
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
            name = "Suspend";
            command = "systemctl suspend";
            binding = "<Super>Escape";
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
            name = "Mission Center";
            command = "missioncenter";
            binding = "<Shift><Ctrl>Escape";
          };

          # Enable gnome extensions
          "org/gnome/shell" = {
            disable-user-extensions = false;
            enabled-extensions = [
              "arcmenu@arcmenu.com"
              "caffeine@patapon.info"
              "gsconnect@andyholmes.github.io"
              "appindicatorsupport@rgcjonas.gmail.com"
              "dash-to-panel@jderose9.github.com"
              "tiling-assistant@leleat-on-github"
              "quicksettings-audio-devices-hider@marcinjahn.com"
            ];
          };
        };
      };
    };

    # Fix nautilus shortcut
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "alacritty";
    };

    environment.sessionVariables = {
      # Fix gnome media inspection
      GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
        pkgs.gst_all_1.gst-plugins-good
        pkgs.gst_all_1.gst-plugins-bad
        pkgs.gst_all_1.gst-plugins-ugly
        pkgs.gst_all_1.gst-libav
      ];
    };

    # Exclude gnome default packages
    environment.gnome.excludePackages = (with pkgs.gnome; [
      gnome-shell-extensions # default ext
      gnome-contacts
      gnome-calendar
      gnome-logs
      gnome-maps
      gnome-music

      geary # email client
      totem # video player
    ]) ++ (with pkgs; [
      gnome-console # replaced with alacritty
      gnome-tour

      snapshot # camera app
      epiphany # web browser
      yelp # help viewer
    ]);
  };
}
