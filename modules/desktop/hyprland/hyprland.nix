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

    home-manager.users.${config.user.name} = { config, ... }: {
      xdg.configFile."hypr/hyprland.conf".source =
        config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config/hyprland.conf";
    };
  };
}
