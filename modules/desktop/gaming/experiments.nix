{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;

  playscope =
    let
      env = {
        "SDL_VIDEODRIVER" = "x11";
        "MANGOHUD" = "0";
        # "MANGOHUD_CONFIGFILE" = "~/.config/MangoHud/MangoHud.conf";
      };
      args = [
        "--adaptive-sync"
        "--immediate-flips"
        "--mangoapp"
        "--force-grab-cursor"
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
  config = lib.mkIf cfg.gaming.enable {
    environment.systemPackages = [ playscope ];

    programs = {
      # VR
      # alvr = {
      #   enable = true;
      #   openFirewall = true;
      # };
    };
  };
}
