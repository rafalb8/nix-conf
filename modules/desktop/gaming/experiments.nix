{ config, pkgs, lib, ... }:
let
  playscope =
    let
      env = {
        "MANGOHUD" = "0";
        "MANGOHUD_CONFIGFILE" = "/home/${config.user.name}/.config/MangoHud/MangoHud.conf";
        "LD_PRELOAD" = ""; # Disable Steam Overlay (--steam breaks gamescope)
      };
      args = [
        "--adaptive-sync"
        "--immediate-flips"
        # "--force-grab-cursor"
        "--mangoapp"
      ];
    in
    pkgs.writeShellScriptBin "playscope" ''
      ${lib.toShellVars env}
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
