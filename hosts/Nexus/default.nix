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
    graphics.intel = true;
  };

  # System settings
  networking.hostName = "Nexus";
  networking.hostId = "b14aa9a5";

  # Zfs settings
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "storage" ];
  boot.zfs.forceImportRoot = false;
  services.zfs.autoScrub.enable = true;

  # Home module settings
  home-manager.users.${config.user.name} = { lib, ... }: {
    # Git config
    programs.git.settings = {
      user.name = "Rafalb8";
      user.email = "rafalb8@hotmail.com";
    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  system.stateVersion = "25.05";
}
