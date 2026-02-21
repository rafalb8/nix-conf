{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.environment.hyprland {
    environment.systemPackages = with pkgs; [ nwg-dock-hyprland nwg-drawer ];

    home-manager.users.${config.user.name} = {
      xdg.configFile."nwg-dock-hyprland/style.css".text = ''
        window {
            background: rgba(25, 25, 25, 0.7);
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        #box {
            padding: 5px;
        }

        button {
            background: transparent;
            border: none;
            margin: 4px;
            padding: 8px;
            transition: all 0.2s ease;
        }

        button:hover {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 12px;
        }
      '';

      home.file.".cache/nwg-dock-pinned".text = ''
        org.gnome.Nautilus
        firefox
        com.mitchellh.ghostty
        dev.zed.Zed
      '';
    };
  };
}
