{ config, lib, pkgs, ... }:
let
  cfg = config.modules.windows;
  win-reboot = lib.custom.wrapScriptBin "win-reboot"
    "efibootmgr -n $(efibootmgr | grep Windows | awk '{print $1}' | sed 's/Boot//; s/\*//') && reboot";
in
{
  options.modules.windows = {
    enable = lib.mkEnableOption "Enable windows dualboot";
  };

  config = lib.mkIf cfg.enable {
    security.wrappers.win-reboot = {
      setuid = true;
      owner = "root";
      group = "root";
      source = "${win-reboot}/bin/win-reboot";
    };

    boot.loader.limine.extraEntries = ''
      /Windows
        protocol: efi_boot_entry
        entry: Windows Boot Manager
    '';

    services.displayManager.sessionPackages = [
      (
        (pkgs.writeTextDir "share/wayland-sessions/windows.desktop" ''
          [Desktop Entry]
          Version=1.0
          Name=Windows
          Exec=/run/wrappers/bin/win-reboot
          Type=Application
        '').overrideAttrs (_: { passthru.providedSessions = [ "windows" ]; })
      )
    ];
  };
}
