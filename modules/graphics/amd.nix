{ config, lib, pkgs, ... }:
let
  cfg = config.modules.graphics;
  desktopEnv = config.modules.desktop.environment;
in
{
  config = lib.mkIf cfg.amd {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.amdgpu = {
      initrd.enable = true;
      # amdvlk.enable = true;
    };

    services.xserver = {
      enable = true;
      videoDrivers = [ "modesetting" ];
      deviceSection = ''
        Option "VariableRefresh" "on"
      '';
    };

    # Wayland GNOME VRR (experimental)
    home-manager.users.${config.user.name}.dconf = lib.mkIf desktopEnv.gnome {
      enable = true;
      settings = {
        "org/gnome/mutter"."experimental-features" = [ "variable-refresh-rate" ];
      };
    };

    # Overcloking
    users.users.${config.user.name}.extraGroups = lib.mkIf cfg.overcloking [ "corectrl" ];
    programs.corectrl = lib.mkIf cfg.overcloking {
      enable = true;
      gpuOverclock.enable = true;
    };

    environment.systemPackages = with pkgs;[ custom.vceenc ];
  };
}
