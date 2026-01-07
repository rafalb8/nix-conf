{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  imports = [ ./streaming.nix ./mangohud.nix ./experiments.nix ];

  config = lib.mkIf cfg.gaming.enable {
    environment.systemPackages = with pkgs; [
      # Tools
      stable.sgdboop
      gamescope
      ludusavi
      # protonup-qt

      # Wine guis
      heroic
      # lutris
      # bottles

      # Emulators
      rpcs3
      custom.eden

      # Games
      prismlauncher # Minecraft launcher
      vintagestory
    ];

    hardware.steam-hardware.enable = true;
    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        protontricks.enable = true;
        extraCompatPackages = with pkgs; [
          steamtinkerlaunch
          proton-ge-bin
        ];
      };

      gamemode.enable = false;
      gamemode.enableRenice = true;
    };

    # Autostart
    autostart = {
      enable = true;
      packages = [ (pkgs.steam // { env.MANGOHUD = "1"; }) ];
    };

    # Enable NTSync (kernel 6.14+)
    boot.kernelModules = [ "ntsync" ];
    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "ntsync-udev-rules";
        text = ''KERNEL=="ntsync", MODE="0660", TAG+="uaccess"'';
        destination = "/etc/udev/rules.d/70-ntsync.rules";
      })
    ];

    # SteamOS Linux optimizations
    # https://github.com/fufexan/nix-gaming/blob/master/modules/platformOptimizations.nix
    boot.kernel.sysctl = {
      # 20-net-timeout.conf
      # This is required due to some games being unable to reuse their TCP ports
      # if they're killed and restarted quickly - the default timeout is too large.
      "net.ipv4.tcp_fin_timeout" = 5;
      # 30-splitlock.conf
      # Prevents intentional slowdowns in case games experience split locks
      # This is valid for kernels v6.0+
      "kernel.split_lock_mitigate" = 0;
      # 30-vm.conf
      # USE MAX_INT - MAPCOUNT_ELF_CORE_MARGIN.
      # see comment in include/linux/mm.h in the kernel tree.
      "vm.max_map_count" = 2147483642;
    };

  };
}
