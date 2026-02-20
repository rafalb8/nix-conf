{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop;
  prntscrn = pkgs.writeShellScriptBin "prntscrn" ''
    set -ex
    DIR="$HOME/Pictures/Screenshots"
    mkdir -p "$DIR"
    ID=$(printf '󰒅  Select Region\n▢  Active Window\n󰍹  Entire Screen' | walker -di)
    case "''${ID:0-1}" in
        0) hyprshot -o "$DIR" -m region -- loupe;;
        1) hyprshot -o "$DIR" -m window -- loupe;;
        2) hyprshot -o "$DIR" -m output -- loupe;;
        *) exit 1;;
    esac
  '';

  audioswitch = pkgs.writeShellScriptBin "audioswitch" ''
    devices=$(wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep -E '[0-9]+\.' | grep -v "Easy Effects" | sed 's/[*│]//g' | sed 's/^ *//')
    list=""
    while read -r line; do
        if [[ -z "$line" ]]; then continue; fi
        if [[ "$line" =~ [Hh]eadphone ]] || [[ "$line" =~ [Hh]eadset ]]; then icon="󰋋 "
        elif [[ "$line" =~ [Hh][Dd][Mm][Ii] ]] || [[ "$line" =~ [Dd]isplay ]]; then icon="󰍹 "
        else icon="󰓃 "
        fi
        list+="''${icon}''${line}\n"
    done <<< "$devices"

    choice=$(echo -e "$list" | walker -d)
    if [ -n "$choice" ]; then
        id=$(echo "$choice" | sed 's/^[^0-9]*//' | cut -d'.' -f1)
        wpctl set-default "$id"
        name=$(echo "$choice" | sed 's/^.*[0-9]\+\. //')
        notify-send "Audio Output" "Switched to: $name" -a "System"
    fi
  '';
in
{
  config = lib.mkIf cfg.environment.hyprland {
    programs.regreet.enable = true;
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      # systemd.setPath.enable = true;
    };

    # Additional services/programs
    programs.waybar.enable = true;
    programs.hyprlock.enable = true;
    services.hypridle.enable = true;
    services.elephant.enable = true;

    # Fix apps not starting
    systemd.user.services.waybar.path = [ "/run/current-system/sw" ];
    systemd.user.services.elephant.path = [ "/run/current-system/sw" ];

    environment.systemPackages = with pkgs; [
      swaynotificationcenter
      nwg-dock-hyprland
      nwg-drawer
      libnotify
      hyprpaper
      hyprshot
      walker

      impala
      bluetui
      playerctl
      brightnessctl

      audioswitch
      prntscrn
      nautilus
      loupe
    ];

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    # Set dark mode in Qt applications
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };

    home-manager.users.${config.user.name} = { config, ... }: {
      wayland.windowManager.hyprland = {
        systemd.enable = false;
      };

      xdg.configFile."hypr/hyprland.conf".source =
        config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config/hyprland.conf";

      xdg.configFile."hypr/hypridle.conf".source =
        config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config/hypridle.conf";

      xdg.configFile."waybar/config".source =
        config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config/waybar/config.jsonc";

      xdg.configFile."waybar/style.css".source =
        config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config/waybar/style.css";

      xdg.configFile."nwg-dock-hyprland/style.css".source =
        config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config/nwg-dock/style.css";

      home.file.".cache/nwg-dock-pinned".text = ''
        org.gnome.Nautilus
        firefox
        com.mitchellh.ghostty
        dev.zed.Zed
      '';

      # Dark mode
      # Set dark mode in GTK applications
      gtk = {
        enable = true;
        theme = {
          name = "Adwaita-dark";
          package = pkgs.gnome-themes-extra;
        };

        iconTheme = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
        };

        font = {
          name = "Sans";
          size = 11;
        };

        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };

        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
      };

      dconf.enable = true;
      dconf.settings = {
        "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      };

      # Cursor
      home.pointerCursor = {
        gtk.enable = true;
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
      };
    };
  };
}
