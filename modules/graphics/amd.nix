{ config, lib, ... }:
let
  cfg = config.modules.graphics;
in
{
  config = lib.mkIf cfg.amd {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    services.xserver = {
      enable = true;
      videoDrivers = [ "modesetting" ];
    };

    hardware.amdgpu = {
      initrd.enable = true;
      # amdvlk.enable = true;
    };

    ## GNOME

    # Enable experimental VRR support
    home-manager.users.${config.user.name} = lib.mkIf config.modules.desktop.environment.gnome {
      dconf = {
        enable = true;
        settings = {
          "org/gnome/mutter"."experimental-features" = [ "variable-refresh-rate" ];
        };
      };
    };
  };
}
