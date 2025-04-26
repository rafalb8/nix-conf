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
    steam.gamescopeSession = {
      enable = false;
      env = {
        STEAM_GAMESCOPE_VRR_SUPPORTED = "1";

        STEAM_MANGOAPP_PRESETS_SUPPORTED = "1";
        STEAM_USE_MANGOAPP = "1";
        STEAM_DISABLE_MANGOAPP_ATOM_WORKAROUND = "1";
        STEAM_MANGOAPP_HORIZONTAL_SUPPORTED = "1";

        STEAM_GAMESCOPE_HAS_TEARING_SUPPORT = "1";
        STEAM_GAMESCOPE_TEARING_SUPPORTED = "1";

        STEAM_GAMESCOPE_HDR_SUPPORTED = "1";

        STEAM_MULTIPLE_XWAYLANDS = "1";

        STEAM_GAMESCOPE_DYNAMIC_FPSLIMITER = "1";
        STEAM_GAMESCOPE_NIS_SUPPORTED = "1";
        STEAM_GAMESCOPE_FANCY_SCALING_SUPPORT = "1";

        STEAM_GAMESCOPE_COLOR_MANAGED = "1";
        STEAM_GAMESCOPE_VIRTUAL_WHITE = "1";
      };
      args = [
        "--mangoapp"
        "-W 3840 -H 2160"
        "-r 60"
      ];
    };

    gamescope.enable = true;
    gamescope.capSysNice = false;

    # VR
    # alvr = {
    #   enable = true;
    #   openFirewall = true;
    # };
  };
}
