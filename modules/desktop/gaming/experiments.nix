{ config, pkgs, ... }:
let
  playscope = with builtins;
    let
      env = {
        "MANGOHUD_CONFIGFILE" = "/home/${config.user.name}/.config/MangoHud/MangoHud.conf";
      };
      args = [
        "--steam"
        "--adaptive-sync"
        "--immediate-flips"
        "--force-grab-cursor"
        "-w 3440 -h 1440"
        "-W 2560 -H 1080"
        "-r 75"
      ];
    in
    pkgs.writeShellScriptBin "playscope" ''
      ${concatStringsSep "\n" (attrValues (mapAttrs (n: v: "export ${n}='${v}'") env))}
      gamescope ${toString args} "$@"
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
    # gamescope.capSysNice = true;

    # VR
    # alvr = {
    #   enable = true;
    #   openFirewall = true;
    # };
  };
}
