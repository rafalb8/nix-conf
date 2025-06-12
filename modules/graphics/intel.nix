{ config, lib, pkgs, ... }:
let
  cfg = config.modules.graphics;
in
{
  config = lib.mkIf cfg.intel {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-sdk # For QSV (Quick Sync Video) support.
        intel-media-driver # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
      ];
    };
    environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
  };
}
