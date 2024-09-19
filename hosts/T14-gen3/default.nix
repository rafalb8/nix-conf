{ config, ... }:
{
  imports = [
    ../../modules

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
      gaming.enable = false;
    };
  };

  # Hostname
  networking.hostName = "T14-gen3";

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
      '';
    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  system.stateVersion = "24.05";
}
