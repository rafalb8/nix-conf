{ config, lib, ... }:
let
  cfg = config.modules.desktop;
  win-reboot = lib.custom.wrapScriptBin "win-reboot"
    "efibootmgr -n $(efibootmgr | grep Windows | awk '{print $1}' | sed 's/Boot//; s/\*//') && reboot";
in
{
  options.modules.desktop = {
    windows = {
      dualboot = lib.mkEnableOption "Enable windows dualboot";
      disk = lib.mkOption {
        type = lib.types.str;
        description = "Limine path. https://codeberg.org/Limine/Limine/src/branch/trunk/CONFIG.md#paths";
        default = "boot()";
      };
    };
    graphical-boot = lib.mkEnableOption "Enable graphical boot";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.windows.dualboot {
      security.wrappers.win-reboot = {
        setuid = true;
        owner = "root";
        group = "root";
        source = "${win-reboot}/bin/win-reboot";
      };

      boot.loader.limine.extraEntries = ''
        /Windows
          protocol: efi
          path: ${cfg.windows.disk}:/EFI/Microsoft/Boot/bootmgfw.efi
      '';
    })

    (lib.mkIf cfg.graphical-boot {
      boot.plymouth.enable = true;

      # Enable "Silent boot"
      boot.consoleLogLevel = 3;
      boot.initrd.verbose = false;
      boot.kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
      ];
    })
  ];
}
