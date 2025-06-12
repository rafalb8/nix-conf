{ config, lib, pkgs, ... }:
let
  cfg = config.modules.graphics;
in
{
  imports = [
    ./nvidia.nix
    ./amd.nix
  ];

  options.modules.graphics = {
    nvidia = lib.mkEnableOption "Nvidia graphics module";
    amd = lib.mkEnableOption "AMD graphics module";
    intel = lib.mkEnableOption "Intel graphics module";
    overcloking = lib.mkEnableOption "Overclocking";
  };

  config = lib.mkIf (cfg.nvidia || cfg.amd) {
    # Tools
    environment.systemPackages = with pkgs; [
      mesa-demos
      vulkan-tools
    ];
  };
}
