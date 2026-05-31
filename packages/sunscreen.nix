{ writeShellScriptBin }:
writeShellScriptBin "sunscreen" ''
  # Restart current script without CAP_SYS_ADMIN
  if getpcaps $$ | grep -q "cap_sys_admin"; then
      exec setpriv --inh-caps -sys_admin "$0" "$@"
  fi

  set -ex

  MONITORS=$(hyprctl monitors -j)
  WIDTH=''${SUNSHINE_CLIENT_WIDTH:-$(jq ".[-1].width" <<< "$MONITORS")}
  HEIGHT=''${SUNSHINE_CLIENT_HEIGHT:-$(jq ".[-1].height" <<< "$MONITORS")}
  FPS=''${SUNSHINE_CLIENT_FPS:-$(jq ".[-1].refreshRate | tonumber" <<< "$MONITORS")}
  MODE="''${WIDTH}x''${HEIGHT}@''${FPS}"

  GAMESCOPE_CMD="exec gamescope -W ''${WIDTH} -H ''${HEIGHT} -r ''${FPS} \
          --immediate-flips --force-grab-cursor --mangoapp -f"

  export MANGOHUD_CONFIG=fps_only

  case $1 in
  "reset") pkill -TERM gamescope ;;
  "mode") hyprctl eval "hl.monitor({output = 'HEADLESS-2', mode = '$MODE'})" ;;
  "monitor")
      POSITION=$(jq -r --arg w "$WIDTH" '.[0] | "\((.width - ($w|tonumber)) / 2)x\(.height)"' <<< "$MONITORS")
      hyprctl eval "hl.monitor({output = 'HEADLESS-2', mode = '$MODE', position = '$POSITION'})" ;;
  "steam")
      pkill -TERM steam && pidwait steam && sleep 3
      $GAMESCOPE_CMD -e -- steam -gamepadui -steamos3 ;;
  *) $GAMESCOPE_CMD -- "$@"
  esac
''
