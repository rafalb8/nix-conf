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
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
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
      home.pointerCursor = {
        gtk.enable = true;
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
      };

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
      };

      dconf = {
        enable = true;
        settings = {
          # Customize gnome
          "org/gnome/mutter".edge-tiling = false; # Controlled by tiling-shell
          "org/gnome/desktop/interface".enable-hot-corners = false;
          "org/gnome/desktop/interface".color-scheme = "prefer-dark"; # Dark mode
          "org/gnome/desktop/wm/preferences".button-layout = "appmenu:minimize,maximize,close"; # Button layout
          ## Resize with right click
          "org/gnome/desktop/wm/preferences".resize-with-right-button = true;
          "org/gnome/desktop/wm/preferences".mouse-button-modifier = "<Super>";

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

          ## Dash to Panel
          "org/gnome/shell/extensions/dash-to-panel" =
            let
              mkPanelConfig = screen: {
                panel-sizes = { "${screen}" = 48; };
                panel-lengths = { "${screen}" = -1; };
                panel-anchors = { "${screen}" = "MIDDLE"; };
                panel-positions = { "${screen}" = "BOTTOM"; };
                panel-element-positions = {
                  "${screen}" = [
                    { "element" = "showAppsButton"; "visible" = false; "position" = "stackedTL"; }
                    { "element" = "activitiesButton"; "visible" = false; "position" = "stackedTL"; }
                    { "element" = "leftBox"; "visible" = false; "position" = "stackedTL"; }
                    { "element" = "taskbar"; "visible" = true; "position" = "centerMonitor"; }
                    { "element" = "centerBox"; "visible" = false; "position" = "stackedBR"; }
                    { "element" = "rightBox"; "visible" = false; "position" = "stackedBR"; }
                    { "element" = "dateMenu"; "visible" = false; "position" = "stackedBR"; }
                    { "element" = "systemMenu"; "visible" = false; "position" = "stackedBR"; }
                    { "element" = "desktopButton"; "visible" = true; "position" = "stackedBR"; }
                  ];
                };
              };

              mkConfig = cfgs: with builtins; {
                panel-sizes = toJSON (foldl' (acc: cfg: acc // cfg.panel-sizes) { } cfgs);
                panel-lengths = toJSON (foldl' (acc: cfg: acc // cfg.panel-lengths) { } cfgs);
                panel-anchors = toJSON (foldl' (acc: cfg: acc // cfg.panel-anchors) { } cfgs);
                panel-positions = toJSON (foldl' (acc: cfg: acc // cfg.panel-positions) { } cfgs);
                panel-element-positions = toJSON (foldl' (acc: cfg: acc // cfg.panel-element-positions) { } cfgs);
              };

              monitor = mkPanelConfig "DEL-1CDG2S3";
              tv = mkPanelConfig "XXX-0x00010000";
              laptop = mkPanelConfig "LEN-0x00000000";
            in
            {
              global-border-radius = 1;
              isolate-workspaces = true;
              show-window-previews = true;

              appicon-margin = 4;
              appicon-padding = 4;

              stockgs-keep-dash = false;
              stockgs-keep-top-panel = true;

              dot-color-dominant = true;
              dot-style-focused = "METRO";
              dot-style-unfocused = "DASHES";

              trans-panel-opacity = 0.40;
              trans-use-custom-opacity = true;
              trans-use-dynamic-opacity = false;
              trans-use-custom-gradient = false;

              intellihide = true;
              intellihide-use-pressure = true;
              intellihide-pressure-time = 1000;
              intellihide-pressure-threshold = 100;
              intellihide-hide-from-windows = true;
              intellihide-show-in-fullscreen = false;
              intellihide-behaviour = "FOCUSED_WINDOWS";

              panel-element-positions-monitors-sync = true;
            } // (mkConfig [ monitor laptop tv ]);

          ## Tiling shell
          "org/gnome/shell/extensions/tilingshell" = {
            inner-gaps = lib.hm.gvariant.mkUint32 0;
            outer-gaps = lib.hm.gvariant.mkUint32 0;
            show-indicator = false;
          };
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
