{ config, pkgs, ... }:
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
      environment.hyprland = true;

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

  hardware.firmware = with pkgs; [
    (linux-firmware.overrideAttrs (final: prev: {
      version = "20250624";
      src = pkgs.fetchFromGitLab {
        owner = "kernel-firmware";
        repo = "linux-firmware";
        rev = "b05fabcd6f2a16d50b5f86c389dde7a33f00bb81";
        hash = "sha256-AvSsyfKP57Uhb3qMrf6PpNHKbXhD9IvFT1kcz5J7khM=";
      };
    }))
  ];

  # Fix MediaTek wifi crashes
  boot.extraModprobeConfig = ''
    options mt7921e disable_aspm=1
  '';

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
        "Clean" = [
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
