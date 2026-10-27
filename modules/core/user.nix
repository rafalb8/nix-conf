{ config, lib, pkgs, ... }@attrs:
{
  # Define a user account.
  users.users.rafalb8 = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups =
      [ "wheel" "cdrom" "input" ]
      ++ lib.optional config.networking.networkmanager.enable "networkmanager"
      ++ lib.optional config.virtualisation.libvirtd.enable "libvirtd"
      ++ lib.optional config.virtualisation.docker.enable "docker"
      ++ lib.optional config.programs.gamemode.enable "gamemode";
  };

  # Allow user to use dmesg
  boot.kernel.sysctl."kernel.dmesg_restrict" = 0;

  home-manager.backupFileExtension = "hm-bak";
  home-manager.users."rafalb8" = {
    imports = [
      ./home.nix
      (import ./completions attrs)
    ];
    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = config.system.stateVersion;
  };
}
