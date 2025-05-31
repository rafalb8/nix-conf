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
        "networkmanager"
        "libvirtd"
        "docker"
        "input"
      ]
      ++ lib.optional config.programs.gamemode.enable "gamemode"
      ++ lib.optional config.modules.graphics.overcloking "corectrl";
  };

  home-manager.users.${config.user.name} = import ./home.nix attrs;
}
