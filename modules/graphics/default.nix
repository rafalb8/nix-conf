{ lib, ... }:
{
  imports = lib.custom.importAll ./.;

  options.modules.graphics = {
    amd = lib.mkEnableOption "AMD graphics module";
    intel = lib.mkEnableOption "Intel graphics module";
    overclocking.enable = lib.mkEnableOption "Overclocking";
  };
}
