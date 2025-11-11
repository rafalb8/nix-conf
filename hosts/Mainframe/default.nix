{ config, ... }:
{
  imports = [
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

      windows-boot = true;
      graphical-boot = true;
      
      environment.gnome = true;

      gaming = {
        enable = true;
        streaming = true;
      };

      waydroid = false;
    };
  };

  # Enable secure boot
  boot.loader.limine.secureBoot.enable = true;

  hardware.logitech.wireless = {
    enable = true;
    # enableGraphical = true;
  };

  # chaotic.mesa-git = {
  #   enable = true;
  #   fallbackSpecialisation = false;
  #   replaceBasePackage = true;
  # };

  # Home module settings
  home-manager.users.${config.user.name} = { lib, ... }: {
    # Git config
    programs.git.settings = {
      user.name = "Rafalb8";
      user.email = "rafalb8@hotmail.com";
    };

    programs.ssh.matchBlocks."AMDC4857" = {
      hostname = "106.120.196.83";
      user = "r.babinski";
      proxyCommand = "nc -X 5 -x 192.168.8.12:1080 %h %p";
    };

    services.easyeffects = {
      autoload = {
        "Normalize" = [
          # Monitor outputs
          "alsa_output.pci-0000_03_00.1.hdmi-stereo:hdmi-output-0"
          "alsa_output.pci-0000_03_00.1.hdmi-stereo-extra2:hdmi-output-2"
        ];
        "Dolby Headphones" = [
          "alsa_output.usb-SteelSeries_Arctis_Nova_7-00.analog-stereo:analog-output"
        ];
      };
    };


    dconf.enable = true;
    dconf.settings."org/gnome/shell"."favorite-apps" = [
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
  };

  # The state version is required and should stay at the version you
  # originally installed.
  system.stateVersion = "24.11";
}
