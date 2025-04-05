{ config, pkgs, ... }:
{
  imports = [
    # Logitech keyboard and mouse support
    ./solaar.nix

    # Include the hardware scan.
    ./hardware-configuration.nix
  ];

  user = {
    name = "rafalb8";
    description = "Rafal Babinski";
  };

  # Hostname
  networking.hostName = "Nix-Rafal";

  # Enable modules
  modules = {
    graphics = {
      amd = true;
      overcloking = false;
    };

    desktop = {
      enable = true;
      environment.gnome = true;
      gaming = {
        enable = true;
        streaming = true;
      };
    };
  };

  chaotic.mesa-git = {
    enable = true;
    fallbackSpecialisation = false;
    replaceBasePackage = true;
  };

  hardware.firmware = [
    (pkgs.linux-firmware.overrideAttrs (old: {
      version = "git";
      src = builtins.fetchGit {
        url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
        rev = "d864697fd38a94092b636c8030843343f265fe69";
      };
    }))
  ];

  # Home module settings
  home-manager.users.${config.user.name} = {
    # Git config
    programs.git = {
      userName = "Rafalb8";
      userEmail = "rafalb8@hotmail.com";
    };

    programs.ssh = {
      enable = true;
      extraConfig = ''
        Host server
          HostName 192.168.0.100

        Host AMDC4857
          HostName 106.120.84.201
          User r.babinski
          ProxyCommand nc -X 5 -x 192.168.0.68:1080 %h %p
      '';
    };

    services.easyeffects = {
      autoload = {
        "Clean" = [ "alsa_output.pci-0000_00_1f.3.analog-stereo:analog-output-lineout" ];
        "Dolby Headphones" = [
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
          "youtube-music.desktop"
        ];
      };
    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  system.stateVersion = "23.11";
}
