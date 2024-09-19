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

    services.xserver = {
      enable = true;
      videoDrivers = [ "modesetting" ];
    };

    hardware.amdgpu.initrd.enable = true;
  };
}
