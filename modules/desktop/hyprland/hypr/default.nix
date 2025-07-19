{ config, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.environment.hyprland {
    home-manager.users.${config.user.name} = { config, lib, ... }: {
      imports = [
        ./binds.nix
        ./input.nix
        ./layout.nix
        ./theme.nix
      ];
    };
  };
}
