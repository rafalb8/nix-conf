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

    # Overcloking
    programs.corectrl = lib.mkIf cfg.overcloking {
      enable = true;
      gpuOverclock.enable = true;
    };

    home-manager.users.${config.user.name} = {
      autostart = lib.mkIf cfg.overcloking {
        enable = true;
        packages = [ pkgs.corectrl ];
      };

      # Wayland GNOME VRR (experimental)
      dconf = lib.mkIf desktopEnv.gnome {
        enable = true;
        settings = {
          "org/gnome/mutter"."experimental-features" = [ "variable-refresh-rate" ];
        };
      };
    };
  };
}
