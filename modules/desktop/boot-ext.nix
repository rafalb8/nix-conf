{ config, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.windows-boot {
      # Alias for rebooting to Windows
      environment.shellAliases.win-reboot =
        "sudo efibootmgr -n $(efibootmgr | grep Windows | awk '{print $1}' | sed 's/Boot//; s/\*//') && reboot";

      boot.loader.limine.extraEntries = ''
        /Windows
          protocol: efi
          path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
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
