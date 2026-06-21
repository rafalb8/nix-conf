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
        intel-media-driver # VA-API (iHD) userspace
        vpl-gpu-rt # oneVPL (QSV) runtime
      ];
    };

    environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
  };
}
