{ config, lib, ... }:
let
  cfg = config.modules.windows;
  win-reboot = lib.custom.wrapScriptBin "win-reboot"
    "efibootmgr -n $(efibootmgr | grep Windows | awk '{print $1}' | sed 's/Boot//; s/\*//') && reboot";
in
{
  options.modules.windows = {
    dualboot = lib.mkEnableOption "Enable windows dualboot";
    disk = lib.mkOption {
      type = lib.types.str;
      description = "Limine path. https://codeberg.org/Limine/Limine/src/branch/trunk/CONFIG.md#paths";
      default = "boot()";
    };
  };

  config = lib.mkIf cfg.dualboot {
    security.wrappers.win-reboot = {
      setuid = true;
      owner = "root";
      group = "root";
      source = "${win-reboot}/bin/win-reboot";
    };

    boot.loader.limine.extraEntries = ''
      /Windows
        protocol: efi
        path: ${cfg.disk}:/EFI/Microsoft/Boot/bootmgfw.efi
    '';
  };
}
