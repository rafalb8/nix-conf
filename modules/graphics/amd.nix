{ config, lib, pkgs, ... }:
let
  cfg = config.modules.graphics;
in
{
  config = lib.mkIf cfg.amd {
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;
    hardware.amdgpu.initrd.enable = true;
    hardware.amdgpu.opencl.enable = true;

    # Overclocking with lact
    services.lact.enable = cfg.overclocking.enable;
    hardware.amdgpu.overdrive.enable = cfg.overclocking.enable;

    # Default to RADV
    environment.variables.AMD_VULKAN_ICD = "RADV";

    environment.systemPackages = with pkgs; [
      nvtopPackages.amd
    ];
  };
}
