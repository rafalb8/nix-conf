{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.environment.hyprland {
    environment.systemPackages = with pkgs; [ nwg-dock-hyprland nwg-drawer ];

    home-manager.users.${config.user.name} = { config, ... }: {
      xdg.configFile."nwg-dock-hyprland/style.css".source =
        config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config/nwg-dock/style.css";

      home.file.".cache/nwg-dock-pinned".text = ''
        org.gnome.Nautilus
        firefox
        com.mitchellh.ghostty
        dev.zed.Zed
      '';
    };
  };
}
