{ config, pkgs, lib, ... }:
let
  cfg = config.modules.server;

  ztemp = pkgs.writeShellScriptBin "ztemp" ''
    DISKS=$(zpool status | grep -oP 'usb-[[:alnum:]_.-]+:0' | sort -u)
    if [[ -z "$DISKS" ]]; then echo "No disk IDs found. Exiting."; exit 1; fi
    for DISK in $DISKS; do
        TEMP=$(sudo smartctl -a "/dev/disk/by-id/$DISK" 2>/dev/null |\
          grep -iP '^\s*\d+\s+Temperature(_Celsius)?' | awk '{print $NF}')
        echo "Disk: $DISK, Temperature: ''${TEMP:-N/A}°C"
    done 
  '';
in
{
  imports = [ ];

  options.modules.server = {
    enable = lib.mkEnableOption "Server module";
  };

  config = lib.mkIf cfg.enable {
    # Use lts kernel
    boot.kernelPackages = pkgs.linuxPackages;

    # Enable SSH server
    services.openssh.enable = true;

    # Enable Tailscale `--advertise-exit-node` feature
    services.tailscale.useRoutingFeatures = "server";

    # Add "motd" with ZFS status
    home-manager.users.${config.user.name} = {
      programs.zsh.initContent = ''
        zpool status -x
      '';
    };

    # Add packages
    environment.systemPackages = with pkgs; [
      ztemp
      smartmontools
    ];
  };
}
