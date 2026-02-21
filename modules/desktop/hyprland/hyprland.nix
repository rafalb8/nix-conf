{ config, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.environment.hyprland {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    home-manager.users.${config.user.name} = {
      xdg.configFile."hypr" = {
        source = ../../../config/hypr;
        recursive = true;
      };
    };
  };
}
