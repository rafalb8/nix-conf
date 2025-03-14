{ config, pkgs, lib, ... }:
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

  # TODO: Remove when mesa 25.0.1 is released
  hardware.graphics = with lib; {
    package = mkForce pkgs.edge.mesa.drivers;
    package32 = mkForce pkgs.edge.driversi686Linux.mesa.drivers;
  };

  # Requires `--impure`
  system.replaceRuntimeDependencies = [
    { original = pkgs.mesa.out; replacement = pkgs.edge.mesa.out; }
    { original = pkgs.driversi686Linux.mesa.out; replacement = pkgs.edge.driversi686Linux.mesa.out; }
  ];

  # TODO: Remove when firmware 20250311 is released
  hardware.firmware = with pkgs; [
    (linux-firmware.overrideAttrs (old: {
      version = "20250311";
      src = builtins.fetchGit {
        url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
        rev = "b4cb02b2dc3330c6e5d69e84a616b1ca5faecf12";
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
        ];
      };
    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  system.stateVersion = "23.11";
}
