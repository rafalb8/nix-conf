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
    graphics.nvidia = true;

    desktop = {
      enable = true;
      environment.gnome = true;
      gaming.enable = true;
    };
  };

  # Hostname
  networking.hostName = "Nix-Rafal";

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
  };

  # The state version is required and should stay at the version you
  # originally installed.
  system.stateVersion = "23.11";
}
