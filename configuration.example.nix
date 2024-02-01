{ config, lib, pkgs, ... }:
{
  imports = [
    # Include the hardware scan.
    ./hardware-configuration.nix
    ./modules
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
      enviroment.gnome = true;
    };
  };

  # Hostname
  networking.hostName = "Nix-Rafal";

  # Home module settings
  home-manager.users.${config.user.name} = {
    # Enviroment variables
    home.sessionVariables = {
      # VARIABLE = "VALUE";
    };

    # Git config
    programs.git = {
      userName = "Rafalb8";
      userEmail = "rafalb8@hotmail.com";
    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  system.stateVersion = "23.11";
}
