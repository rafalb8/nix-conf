{ config, lib, pkgs, ... }:
let
  cfg = config.modules.hyprland;
  prntscrn = pkgs.writeShellScriptBin "prntscrn" ''
    set -ex
    DIR="$HOME/Pictures/Screenshots"
    mkdir -p "$DIR"
    ID=''${1:-$(printf '󰒅  Select Region\n▢  Active Window\n󰍹  Entire Screen' | walker -di)}
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
    fi
  '';

  powermenu = pkgs.writeShellScriptBin "powermenu" ''
    ID=$(echo -e "󰍃  Log Out\n󰤄  Suspend\n󰜉  Reboot\n󰐥  Shutdown\n󰖳  Switch to Windows" | walker -di)
    case $ID in
        0) loginctl terminate-user $(whoami) ;;
        1) systemctl suspend ;;
        2) systemctl reboot ;;
        3) systemctl poweroff ;;
        4) win-reboot ;;
    esac
  '';

  hyprvs = lib.mkIf (config.services.sunshine.enable) (pkgs.writeShellScriptBin "hyprvs" ''
    hyprctl output create headless HEADLESS-2
    hyprctl keyword workspace 9, monitor:HEADLESS-2

    cat >/tmp/sunshine_apps.json <<EOF
    {
      "env": {},
      "apps": [
        {
          "name": "Desktop",
          "image-path": "desktop.png",
          "prep-cmd": [{"do": "${pkgs.custom.sunscreen}/bin/sunscreen monitor"}]
        }
      ]
    }
    EOF

    sunshine /tmp/sunshine.conf \
            file_apps=/tmp/sunshine_apps.json \
            stream_audio=disabled \
            system_tray=disabled \
            output_name=1

    hyprctl output remove headless HEADLESS-2
  '');
in
{ config.environment.systemPackages = lib.mkIf cfg.enable [ prntscrn audioswitch powermenu hyprvs ]; }
