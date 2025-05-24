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

  # Enable modules
  modules = {
    server.enable = true;
  };

  # Hostname
  networking.hostName = "Nexus";

  # Home module settings
  home-manager.users.${config.user.name} = { lib, ... }: {
    # Git config
    programs.git = {
      userName = "Rafalb8";
      userEmail = "rafalb8@hotmail.com";
    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  system.stateVersion = "25.05";
}
