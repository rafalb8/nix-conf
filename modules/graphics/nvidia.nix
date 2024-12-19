{ config, lib, pkgs, ... }:
let
  cfg = config.modules.graphics;
  /*
    nvidia-vrr = pkgs.writeShellScriptBin "nvidia-vrr" ''
    [[ $# -eq 0 ]] && { echo "Usage: $0 [true|false] [-i|--indicator]"; exit 1; }

    g() { nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 {ForceCompositionPipeline=$1, AllowGSYNCCompatible=On}"; }
    i() { nvidia-settings -a "ShowVRRVisualIndicator=$1"; }

    # Enable GSync
    [[ "$*" =~ [Tt1] ]] && g Off || g On
    # Enable Indicator
    [[ "$*" =~ (-i|--indicator) ]] && i 1 || i 0
    '';
  */
in
{
  config = lib.mkIf cfg.nvidia {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Load nvidia driver for Xorg and Wayland
    services.xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };

    hardware.nvidia = {
      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      powerManagement.enable = true;
      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      open = true;

      # Enable the Nvidia settings menu accessible via `nvidia-settings`.
      nvidiaSettings = false;

      # https://wiki.nixos.org/wiki/Nvidia#Screen_tearing_issues
      forceFullCompositionPipeline = true;

      # Patch nvidia driver to enable NvFBC
      package = /* pkgs.custom.nvidia.nvfbc */ config.boot.kernelPackages.nvidiaPackages.beta;
    };

    # Enable fbdev (might be added by default in the future)
    boot.kernelParams = [ "nvidia-drm.fbdev=1" ];

    # Enable docker gpu support
    hardware.nvidia-container-toolkit.enable = true;

    environment.systemPackages = [
      # rigaya/NVEnc
      (pkgs.custom.nvencc.override { nvidia = config.hardware.nvidia.package; })
      # nvidia-vrr
    ];

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

    # Fix Sleep (might be not needed in the future)
    systemd.services = {
      "gnome-suspend" = {
        description = "suspend gnome shell";
        before = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
          "nvidia-suspend.service"
          "nvidia-hibernate.service"
        ];
        wantedBy = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = ''${pkgs.procps}/bin/pkill -f -STOP ${pkgs.gnome-shell}/bin/gnome-shell'';
        };
      };

      "gnome-resume" = {
        description = "resume gnome shell";
        after = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
          "nvidia-resume.service"
        ];
        wantedBy = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = ''${pkgs.procps}/bin/pkill -f -CONT ${pkgs.gnome-shell}/bin/gnome-shell'';
        };
      };
    };
  };
}
