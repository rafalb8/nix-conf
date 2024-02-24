{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.enviroment.gnome {
    # Enable the GNOME Desktop Environment.
    services.xserver = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    # Add Gnome packages
    environment.systemPackages =
      (with pkgs.gnomeExtensions; [
        # Gnome Extensions
        arcmenu
        caffeine
        gsconnect
        appindicator
        dash-to-panel
        tiling-assistant
        quick-settings-audio-devices-hider
      ])
      ++
      (with pkgs; [
        # Essentials
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
          "org/gnome/shell".enabled-extensions = [
            "dash-to-panel@jderose9.github.com"
            "arcmenu@arcmenu.com"
            "tiling-assistant@leleat-on-github"
            "gsconnect@andyholmes.github.io"
            "quicksettings-audio-devices-hider@marcinjahn.com"
            "appindicatorsupport@rgcjonas.gmail.com"
            "caffeine@patapon.info"
          ];
        };
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
