{ config, pkgs, lib, ... }:
let
  playscope =
    let
      env = {
        # "MANGOHUD" = "0";
        # "MANGOHUD_CONFIGFILE" = "/home/${config.user.name}/.config/MangoHud/MangoHud.conf";
        # "LD_PRELOAD" = ""; # Disable Steam Overlay (--steam/-e breaks gamescope)
      };
      args = [
        # "--adaptive-sync"
        # "--immediate-flips"
        # "--force-grab-cursor"
        "--steam"
        # "--mangoapp"
        "--backend sdl"
      ];
      toExportShellVars = vars: lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "export ${k}=${v}") vars);
    in
    pkgs.writeShellScriptBin "playscope" ''
      ${toExportShellVars env}
      gamemoderun gamescope ${builtins.toString args} "$@"
    '';
in
{
  environment.systemPackages = [ playscope ];

  programs = {
    gamescope.enable = true;
    gamescope.capSysNice = false;

    # VR
    # alvr = {
    #   enable = true;
    #   openFirewall = true;
    # };
  };
}
