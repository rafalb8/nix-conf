{ config, lib, ... }:
let
  cfg = config.modules.graphics;
in
{
  config = lib.mkIf cfg.amd {
    # Enable OpenGL
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };
}
