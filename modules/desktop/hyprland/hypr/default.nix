{ config, ... }:
{
  home-manager.users.${config.user.name} = { config, lib, ... }: {
    imports = [
      ./binds.nix
      ./input.nix
      ./layout.nix
      ./theme.nix
    ];
  };
}
