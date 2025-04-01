{ config, pkgs, lib, ... }:
let
  cfg = config.programs.fastflix;
in
{
  # https://github.com/cdgriffith/FastFlix
  options.programs.fastflix = {
    enable = lib.mkEnableOption "FastFlix - free GUI for H.264, HEVC and AV1 hardware and software encoding";

    package = lib.mkPackageOption pkgs.custom "fastflix" {
      extraDescription = "Override the default FastFlix package";
    };

    recommendedPackges = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ pkgs.custom.vceencc pkgs.hdr10plus_tool ];
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ] ++ cfg.recommendedPackges;
  };
}
