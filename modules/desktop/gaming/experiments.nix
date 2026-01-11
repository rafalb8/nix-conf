{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;

  playscope =
    let
      env = {
        "MANGOHUD" = "0";
        # "MANGOHUD_CONFIGFILE" = "~/.config/MangoHud/MangoHud.conf";
        # "SDL_VIDEODRIVER" = "x11";
      };
      args = [
        # "--backend sdl"
        "--adaptive-sync"
        "--immediate-flips"
        "--mangoapp"
        "--force-grab-cursor"
        "-b"
        "-W 2305"
        "-H 1408"
      ];
    in
    pkgs.writeShellScriptBin "playscope" ''
      ${lib.custom.toExportShellVars env}
      gamescope ${toString args} "$@"
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
