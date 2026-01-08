{ config, lib, ... }:
let
  cfg = config.modules.graphics;
in
{
  config = lib.mkIf cfg.amd {
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;
    hardware.amdgpu.initrd.enable = true;

    # Overclocking with lact
    services.lact.enable = cfg.overclocking;
    hardware.amdgpu.overdrive.enable = cfg.overclocking;

    # Default to RADV
    environment.variables.AMD_VULKAN_ICD = "RADV";
  };
}
