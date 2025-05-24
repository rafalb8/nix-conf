{ config, lib, pkgs, ... }@attrs:
{
  # Define a user account.
  users.users.${config.user.name} = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = config.user.description;
    openssh.authorizedKeys.keys = [
    	"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMR8zRRtw+n3cYr2dNixiElLzgNLU+RQdhXf/WwA/B4N rafalb8@Mainframe"
    ];
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
