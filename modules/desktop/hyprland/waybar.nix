{ config, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.environment.hyprland {
    programs.waybar.enable = true;
    systemd.user.services.waybar.path = [ "/run/current-system/sw" ];
    home-manager.users.${config.user.name} = { config, ... }: {
      xdg.configFile."waybar/config".source =
        config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config/waybar/config.jsonc";

      xdg.configFile."waybar/style.css".source =
        config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config/waybar/style.css";
    };
  };
}
