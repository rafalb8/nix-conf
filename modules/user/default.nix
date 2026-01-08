{ config, lib, pkgs, ... }@attrs:
{
  # Define a user account.
  users.users.${config.user.name} = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = config.user.description;
    extraGroups =
      [
        "wheel"
        "cdrom"
        "input"
      ]
      ++ lib.optional config.networking.networkmanager.enable "networkmanager"
      ++ lib.optional config.virtualisation.libvirtd.enable "libvirtd"
      ++ lib.optional config.virtualisation.docker.enable "docker"
      ++ lib.optional config.programs.gamemode.enable "gamemode";
  };

  home-manager.backupFileExtension = "hm-bak";
  home-manager.users.${config.user.name} = {
    imports = [
      ./home.nix
      (import ./completions attrs)
    ];
    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = config.system.stateVersion;
  };
}
