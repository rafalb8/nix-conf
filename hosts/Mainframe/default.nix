{ config, ... }:
{
  imports = [
    # Logitech keyboard and mouse support
    ./solaar

    # Include the hardware scan.
    ./hardware-configuration.nix
  ];

  user = {
    name = "rafalb8";
    description = "Rafal Babinski";
  };

  # Hostname
  networking.hostName = "Mainframe";

  # Enable modules
  modules = {
    graphics = {
      amd = true;
      overcloking = false;
    };

    desktop = {
      enable = true;
      graphicalBoot = true;
      environment.gnome = true;

      gaming = {
        enable = true;
        streaming = true;
      };

      waydroid = false;
    };
  };

  # chaotic.mesa-git = {
  #   enable = true;
  #   fallbackSpecialisation = false;
  #   replaceBasePackage = true;
  # };

  # Home module settings
  home-manager.users.${config.user.name} = { lib, ... }: {
    # Git config
    programs.git = {
      userName = "Rafalb8";
      userEmail = "rafalb8@hotmail.com";
    };

    programs.ssh.matchBlocks."AMDC4857" = {
      hostname = "106.120.84.201";
      user = "r.babinski";
      proxyCommand = "nc -X 5 -x 192.168.0.68:1080 %h %p";
    };

    services.easyeffects = {
      autoload = {
        "Dolby Headphones" = [
          "alsa_output.pci-0000_03_00.1.hdmi-stereo-extra2:hdmi-output-2"
          "alsa_output.pci-0000_0e_00.6.analog-stereo:analog-output-lineout"
          "alsa_output.usb-SteelSeries_SteelSeries_Arctis_1_Wireless-00.analog-stereo:analog-output"
        ];
      };
    };

    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell"."favorite-apps" = [
          "org.gnome.Nautilus.desktop"
          "firefox.desktop"
          "Alacritty.desktop"
          "code.desktop"
          "obsidian.desktop"
          "steam.desktop"
          "discord.desktop"
          "com.github.wwmm.easyeffects.desktop"
          "com.github.iwalton3.jellyfin-media-player.desktop"
          "com.github.th_ch.youtube_music.desktop"
        ];

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
          } // (mkConfig [ monitor ]);
      };
    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  system.stateVersion = "24.11";
}
