{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;

  env = {
    "MANGOHUD" = "0";
    "SDL_VIDEODRIVER" = "x11";
  };

  args = [
    "--adaptive-sync"
    "--immediate-flips"
    "--mangoapp"
    "--force-grab-cursor"
    "-b"
    "-W 2503"
    "-H 1408"
    "--backend sdl"
  ];

  playscope = pkgs.writeShellScriptBin "playscope" ''
    ${lib.custom.toExportShellVars env}

    # Separate args: everything before -- is pre, everything after is post
    pre=()
    while [[ $# -gt 0 ]]; do
      [[ "$1" == "--" ]] && { shift; break; }
      pre+=("$1")
      shift
    done

    # If no -- was found, what we thought was 'pre' is actually the game command
    if [[ $# -eq 0 && ''${#pre[@]} -gt 0 ]]; then
      exec gamescope ${toString args} -- env LD_PRELOAD="$LD_PRELOAD" "''${pre[@]}"
    else
      exec gamescope ${toString args} "''${pre[@]}" -- env LD_PRELOAD="$LD_PRELOAD" "$@"
    fi
  '';
in
{
  config = lib.mkIf cfg.gaming.enable {
    environment.systemPackages = [ playscope ];
  };
}
