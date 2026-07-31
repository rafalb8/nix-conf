{ writeShellScriptBin }:
writeShellScriptBin "sunscreen" ''
  # Restart current script without CAP_SYS_ADMIN
  if getpcaps $$ | grep -q "cap_sys_admin"; then
      exec setpriv --inh-caps -sys_admin "$0" "$@"
  fi

  DISPLAY="HEADLESS-1"

  set -ex

  MONITOR=$(hyprctl monitors -j | jq -r 'first(.[] | select(.name == "'$DISPLAY'")) // .[0]')
  WIDTH=''${SUNSHINE_CLIENT_WIDTH:-$(jq -r '.width' <<< "$MONITOR")}
  HEIGHT=''${SUNSHINE_CLIENT_HEIGHT:-$(jq -r '.height' <<< "$MONITOR")}
  FPS=''${SUNSHINE_CLIENT_FPS:-$(jq -r '.refreshRate | tonumber | round' <<< "$MONITOR")}
  MODE="''${WIDTH}x''${HEIGHT}@''${FPS}"

  GAMESCOPE_CMD="exec gamescope -W ''${WIDTH} -H ''${HEIGHT} -r ''${FPS} \
          --immediate-flips --force-grab-cursor --mangoapp -f"

  export MANGOHUD_CONFIG=fps_only

  case $1 in
    "reset") pkill -TERM gamescope ;;
    "mode") hyprctl eval "hl.monitor({output = '$DISPLAY', mode = '$MODE'})" ;;
    "steam")
        if pgrep -x steam >/dev/null; then
            pkill -TERM -x steam || true
            timeout 5 pidwait -x steam || pkill -9 -x steam || true
            sleep 2
        fi
        $GAMESCOPE_CMD -e -- steam -gamepadui -steamos3 ;;
    *) $GAMESCOPE_CMD -- "$@"
  esac
''
