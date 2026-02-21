{ config, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.environment.hyprland {
    services.hypridle.enable = true;
    home-manager.users.${config.user.name} = { config, ... }: {
      xdg.configFile."hypr/hypridle.conf".source =
        config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config/hypridle.conf";
    };
  };
}
