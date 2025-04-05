{ config, pkgs, lib, ... }:
let
  playscope =
    let
      env = {
        "MANGOHUD" = "0";
        "MANGOHUD_CONFIGFILE" = "/home/${config.user.name}/.config/MangoHud/MangoHud.conf";
        "LD_PRELOAD" = ""; # Disable Steam OVerlay (--steam breaks gamescope)
      };
      args = [
        # "--steam"
        "--adaptive-sync"
        "--immediate-flips"
        "--force-grab-cursor"
        "--mangoapp"
        "-w 3440 -h 1440"
        "-W 2560 -H 1080"
        "-r 75"
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
    # steam.gamescopeSession = {
    #   enable = true;
    #   env = {
    #     STEAM_GAMESCOPE_VRR_SUPPORTED = "1";
    #   };
    #   args = [
    #     "-w 3440 -h 1440"
    #     "-W 2560 -H 1080"
    #     "-r 75"
    #     "--mangoapp"
    #     "--adaptive-sync"
    #     "--immediate-flips"
    #   ];
    # };

    gamescope.enable = true;
    gamescope.capSysNice = false;

    # VR
    # alvr = {
    #   enable = true;
    #   openFirewall = true;
    # };
  };
}
