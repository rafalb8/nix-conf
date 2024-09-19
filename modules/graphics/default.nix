{ lib, ... }:
{
  imports = [
    ./nvidia.nix
    ./amd.nix
  ];

  options.modules.graphics = {
    nvidia = lib.mkEnableOption "Nvidia graphics module";
    amd = lib.mkEnableOption "AMD graphics module";
  };
}
