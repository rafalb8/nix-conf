{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.enviroment.gnome {
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
        gnome.gnome-tweaks
        gnome.ghex
        mission-center
        adw-gtk3
      ]);

    # Setup home for gnome desktop
    home-manager.users.${config.user.name} = {
      dconf = {
        enable = true;
        settings = {
          "org/gnome/desktop/interface".color-scheme = "prefer-dark";
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

      home.file = {
        # 
        ".hidden".text = ''
          Desktop
          Documents
          Downloads
          Music
          Pictures
          Public
          Templates
          Videos
          go
        '';
      };
    };

    # Fix gnome media inspection
    environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
      pkgs.gst_all_1.gst-plugins-good
      pkgs.gst_all_1.gst-plugins-bad
      pkgs.gst_all_1.gst-plugins-ugly
      pkgs.gst_all_1.gst-libav
    ];

    # Exclude gnome default packages
    environment.gnome.excludePackages = (with pkgs.gnome; [
      gnome-shell-extensions # default ext

      gnome-contacts
      gnome-calendar
      gnome-logs
      gnome-maps
      gnome-music

      epiphany # web browser
      geary # email client
      totem # video player
      yelp # help viewer

    ]) ++ (with pkgs; [
      gnome-console # replaced with gnome-terminal
      gnome-tour
      snapshot
    ]);
  };
}
