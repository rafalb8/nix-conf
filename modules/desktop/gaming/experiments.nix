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

    pre=()
    while [[ $# -gt 0 ]]; do
      [[ "$1" == "--" ]] && { shift; break; }
      pre+=("$1")
      shift
    done

    if [[ $# -eq 0 && ''${#pre[@]} -gt 0 ]]; then
      exec gamescope ${toString args} -- "''${pre[@]}"
    else
      exec gamescope ${toString args} "''${pre[@]}" -- "$@"
    fi
  '';
in
{
  config = lib.mkIf cfg.gaming.enable {
    environment.systemPackages = [ playscope ];
  };
}
