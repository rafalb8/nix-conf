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

  # Enable modules
  modules = {
    graphics.amd = true;

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

  hardware.firmware = with pkgs; [
    (linux-firmware.overrideAttrs (old: {
      version = "git";
      src = builtins.fetchGit {
        url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
        rev = "588505068c48fe07b1cfa32c5f3acd4395ec9482";
      };
    }))
  ];

  # Hostname
  networking.hostName = "Nix-Rafal";

  # Use cachyos kernel
  boot.kernelPackages = pkgs.linuxPackages_cachyos;

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

    xdg = {
      enable = true;
      configFile = {
        # Easyeffects config
        "easyeffects" = {
          source = ../../dotfiles/easyeffects;
          recursive = true;
        };
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
        ];
      };
    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  system.stateVersion = "23.11";
}
