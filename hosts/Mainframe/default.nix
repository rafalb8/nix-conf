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

      waydroid = true;
    };
  };

  # chaotic.mesa-git = {
  #   enable = true;
  #   fallbackSpecialisation = false;
  #   replaceBasePackage = true;
  # };

  # Home module settings
  home-manager.users.${config.user.name} = {
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
          "com.github.iwalton3.jellyfin-media-player.desktop"
          "com.github.wwmm.easyeffects.desktop"
          "com.github.th_ch.youtube_music.desktop"
        ];

        "org/gnome/shell/extensions/dash-to-panel" =
          let
            panel = "GSM-0x000231e1";
          in
          {
            appicon-margin = 4;
            trans-use-custom-opacity = true;
            trans-use-dynamic-opacity = true;
            trans-panel-opacity = 0.40;
            stockgs-keep-top-panel = true;
            show-window-previews = true;
            isolate-workspaces = true;
            panel-postions = ''{"${panel}":"LEFT"}'';
            panel-element-positions = builtins.toJSON {
              "${panel}" = [
                { "element" = "showAppsButton"; "visible" = false; "position" = "stackedTL"; }
                { "element" = "activitiesButton"; "visible" = false; "position" = "stackedTL"; }
                { "element" = "leftBox"; "visible" = false; "position" = "stackedTL"; }
                { "element" = "taskbar"; "visible" = true; "position" = "stackedTL"; }
                { "element" = "centerBox"; "visible" = false; "position" = "stackedBR"; }
                { "element" = "rightBox"; "visible" = false; "position" = "stackedBR"; }
                { "element" = "dateMenu"; "visible" = false; "position" = "stackedBR"; }
                { "element" = "systemMenu"; "visible" = false; "position" = "stackedBR"; }
                { "element" = "desktopButton"; "visible" = true; "position" = "stackedBR"; }
              ];
            };
          };

        "org/gnome/shell/extensions/arcmenu" = {
          dash-to-panel-standalone = true;
          arcmenu-hotkey = [ ];
          menu-button-icon = "Distro_Icon";
          distro-icon = 22;
          custom-menu-button-icon-size = 24.0;
        };
      };
    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  system.stateVersion = "24.11";
}
