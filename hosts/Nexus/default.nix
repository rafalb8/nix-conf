{ ... }:
{
  imports = [
    # Include the hardware scan.
    ./hardware-configuration.nix
  ];

  # System settings
  networking.hostName = "Nexus";
  networking.hostId = "b14aa9a5";

  # Enable modules
  modules = {
    server.enable = true;
    graphics.intel = true;
  };

  # Zfs settings
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "storage" ];
  boot.zfs.forceImportRoot = false;
  services.zfs.autoScrub.enable = true;

  # The state version is required and should stay at the version you
  # originally installed.
  system.stateVersion = "25.05";
}
