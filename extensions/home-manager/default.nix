# Home-Manager extensions
{ config, ... }:
{
  home-manager.users.${config.user.name} = {
    imports = [
      ./autostart.nix
    ];
  };
}
