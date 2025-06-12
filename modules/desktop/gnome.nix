{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.environment.gnome {
    # Enable the GNOME Desktop Environment.
    services = {
      xserver.enable = true;
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
      gvfs.enable = true;
    };

    # Add Gnome packages
    environment.systemPackages =
      # Gnome Extensions
      (with pkgs.gnomeExtensions; [
        caffeine
        gsconnect
        pip-on-top
        tiling-shell
        appindicator
        dash-to-panel
        quick-settings-audio-devices-hider
      ])
      ++
      # Essentials
      (with pkgs; [
        # gnome.gnome-terminal
        adwaita-icon-theme
        mission-center
        gnome-firmware
        # gnome-tweaks
        adw-gtk3
        ghex
      ]);

    # Set dark mode in Qt applications
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };

    home-manager.users.${config.user.name} = { lib, ... }: {
      # Set dark mode in GTK applications
      gtk = {
        enable = true;
        theme = {
          name = "Adwaita-dark";
          package = pkgs.gnome-themes-extra;
        };
      };

      dconf = {
        enable = true;
        settings = {
          # Customize gnome
          "org/gnome/mutter".edge-tiling = false; # Controlled by tiling-shell
          "org/gnome/desktop/interface".enable-hot-corners = false;
          "org/gnome/desktop/interface".color-scheme = "prefer-dark"; # Dark mode
          "org/gnome/desktop/wm/preferences".button-layout = "appmenu:minimize,maximize,close"; # Button layout

          # Enable gnome extensions
          "org/gnome/shell" = {
            disable-user-extensions = false;
            enabled-extensions = [
              "caffeine@patapon.info"
              "gsconnect@andyholmes.github.io"
              "pip-on-top@rafostar.github.com"
              "tilingshell@ferrarodomenico.com"
              "appindicatorsupport@rgcjonas.gmail.com"
              "dash-to-panel@jderose9.github.com"
              "quicksettings-audio-devices-hider@marcinjahn.com"
            ];
          };

          # Disable mouse acceleration
          "org/gnome/desktop/peripherals/mouse".accel-profile = "flat";

          # Enable fractional scaling
          "org/gnome/mutter"."experimental-features" = [
            "scale-monitor-framebuffer"
            "xwayland-native-scaling"
          ];

          # TextEditor
          "org/gnome/TextEditor" = {
            restore-session = false;
            style-scheme = "builder-dark";
          };

          # Customize extensions
          ## PiP on top
          "org/gnome/shell/extensions/pip-on-top".stick = true;

          ## Tiling shell
          "org/gnome/shell/extensions/tilingshell".inner-gaps = lib.hm.gvariant.mkUint32 0;
          "org/gnome/shell/extensions/tilingshell".outer-gaps = lib.hm.gvariant.mkUint32 0;
          ### Disable default keybindings
          "org/gnome/desktop/wm/keybindings".maximize = [ ]; # Super+Up
          "org/gnome/desktop/wm/keybindings".unmaximize = [ ]; # Super+Down
          "org/gnome/mutter/keybindings".toggle-tiled-left = [ ]; # Super+Left
          "org/gnome/mutter/keybindings".toggle-tiled-right = [ ]; # Super+Right

          # Shortcuts / Keybinds
          "org/gnome/desktop/wm/keybindings" = {
            close = [ "<Super>w" ];
            switch-applications = [ "<Super>Tab" ];
            switch-applications-backward = [ "<Shift><Super>Tab" ];
            switch-windows = [ "<Alt>Tab" ];
            switch-windows-backward = [ "<Shift><Alt>Tab" ];
            toggle-fullscreen = [ "<Shift><Super>Return" ];
          };

          "org/gnome/settings-daemon/plugins/media-keys" = {
            mic-mute = [ "<Super>v" ];

            ## Enable custom keybindings
            custom-keybindings = [
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
            ];
          };
          ## Custom keybinds definitions
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

          ## Disable keybindings
          "org/gnome/mutter/wayland/keybindings".restore-shortcuts = [ ];
          "org/gnome/shell/keybindings".toggle-message-tray = [ ];
        };
      };
    };

    # Fix nautilus shortcut
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "alacritty";
    };

    # Fix Gnome crash when logging in too quickly xD
    # https://discourse.nixos.org/t/gnome-display-manager-fails-to-login-until-wi-fi-connection-is-established/50513/10
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;

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
    environment.gnome.excludePackages = (with pkgs; [
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
