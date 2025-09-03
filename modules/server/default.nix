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

    # Set authorized keys for SSH
    users.users.${config.user.name}.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMR8zRRtw+n3cYr2dNixiElLzgNLU+RQdhXf/WwA/B4N rafalb8@Mainframe"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEGH3v2xaa15Z6+qCwC32zezwYybR3+cxYNLL/bRcDa8 T14-gen3"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQ1AZR49tTS0jKf5EBXLUXkIQHolj1/+tQweqmwlzXQ u0_a447@localhost"
    ];

    # Enable Tailscale `--advertise-exit-node` feature
    services.tailscale.useRoutingFeatures = "server";

    # Run cache output of zpool status
    systemd.services.zpool-status = {
      startAt = "daily";
      environment.OUT = "/tmp/zpool-status";
      script = ''
        STATUS=$(zpool status -x)
        DATE=$(date --rfc-3339=seconds)

        if [[ "$STATUS" != "all pools are healthy" ]]; then
          echo "❌: [$DATE]\n$STATUS" > $OUT
        else
          echo "✔️: All pools are healthy [$DATE]" > $OUT
        fi
      '';
    };

    home-manager.users.${config.user.name} = {
      programs.zsh.initContent = ''
        # Print cached zpool status
        \cat /tmp/zpool-status
      '';
    };

    environment.shellInit = ''
      # ffmpeg helper
      ## ac3 file.mkv 0 .en => file.en.ac3
      ac3() {ffmpeg -i "$1" -map 0:a:''${2:-0} -c:a ac3 -ac 6 -b:a 640k -map_metadata -1 "''${1%.*}''${3:-.en}.ac3"}
    '';

    # Add packages
    environment.systemPackages = with pkgs; [
      ztemp
      smartmontools
    ];
  };
}
