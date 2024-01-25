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
        mission-center
        adw-gtk3
      ]);

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
