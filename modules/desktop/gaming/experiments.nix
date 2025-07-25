{ pkgs, lib, ... }:
let
  playscope =
    let
      env = {
        "SDL_VIDEODRIVER" = "x11";
        "MANGOHUD_CONFIGFILE" = "~/.config/MangoHud/MangoHud.conf";
      };
      args = [
        "--adaptive-sync"
        "--immediate-flips"
        "--mangoapp"
        "--backend sdl"
        "-b"
        "-W 2305"
        "-H 1408"
      ];
      toExportShellVars = vars: lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "export ${k}=${v}") vars);
    in
    pkgs.writeShellScriptBin "playscope" ''
      ${toExportShellVars env}
      gamescope ${builtins.toString args} "$@"
    '';
in
{
  environment.systemPackages = [ playscope ];

  programs = {
    # VR
    # alvr = {
    #   enable = true;
    #   openFirewall = true;
    # };
  };
}
