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
      overclocking = true;
    };

    desktop = {
      enable = true;
      graphical-boot = true;
      environment.kde = true;

      windows = {
        dualboot = true;
        disk = "guid(16f1dd3d-e30e-408d-9404-13bdd6c6951e)";
      };

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

  # Home module settings
  home-manager.users.${config.user.name} = {
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
          "alsa_output.pci-0000_03_00.1.hdmi-stereo:HDMI _ DisplayPort"
        ];
        "Dolby Headphones" = [
          "alsa_output.usb-SteelSeries_Arctis_Nova_7-00.analog-stereo:Analog Output"
        ];
      };
    };
  };

  services.flatpak.enable = true;

  # The state version is required and should stay at the version you
  # originally installed.
  system.stateVersion = "24.11";
}
