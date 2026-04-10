{ writeShellScriptBin }:
writeShellScriptBin "sunscreen" ''
  # Restart current script without CAP_SYS_ADMIN
  if getpcaps $$ | grep -q "cap_sys_admin"; then
    exec setpriv --inh-caps -sys_admin "$0" "$@"
  fi

  set -ex

  export MANGOHUD_CONFIG=preset=1

  MONITORS=$(hyprctl monitors -j)
  WIDTH=''${SUNSHINE_CLIENT_WIDTH:-$(jq ".[-1].width" <<< "$MONITORS")}
  HEIGHT=''${SUNSHINE_CLIENT_HEIGHT:-$(jq ".[-1].height" <<< "$MONITORS")}
  FPS=''${SUNSHINE_CLIENT_FPS:-$(jq ".[-1].refreshRate | tonumber" <<< "$MONITORS")}
  PROFILE="''${WIDTH}x''${HEIGHT}@''${FPS}"

  GAMESCOPE_CMD="exec gamescope -W ''${WIDTH} -H ''${HEIGHT} -r ''${FPS} \
          --immediate-flips --force-grab-cursor --mangoapp -f"

  case $1 in
    "reset") pkill -TERM gamescope ;;
    "mode") hyprctl keyword monitor HEADLESS-2, ''${PROFILE}, auto, 1 ;;
    "monitor")
      POSITION=$(jq -r --arg w "$WIDTH" '.[0] | "\((.width - ($w|tonumber)) / 2)x\(.height)"' <<< "$MONITORS")
      hyprctl keyword monitor HEADLESS-2, ''${PROFILE}, ''${POSITION}, 1 ;;
    "steam")
      pkill -TERM steam && pidwait steam && sleep 3
      $GAMESCOPE_CMD -e -- steam -gamepadui -steamos3 ;;
    *) $GAMESCOPE_CMD -- "$@"
  esac
''
