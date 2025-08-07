{ config, pkgs, lib, ... }:
let
  cfg = config.modules.secureboot;
in
{
  # Instructions: https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
  # TLDR:
  # sudo nix run nixpkgs#sbctl -- create-keys
  # [nix]: modules.secureboot.enable = true; => rebuild
  # sudo sbctl verify
  # [firmware]: Enable Secure Boot => "Reset to Setup Mode" or just remove PK keys
  # sudo sbctl enroll-keys --microsoft
  # If fails: sudo chattr -i (files printed in sbctl enroll-keys) => repeat enroll-keys
  # reboot
  # bootctl status

  options.modules.secureboot = {
    enable = lib.mkEnableOption "Enable Secure Boot with lanzaboote";
  };

  config = lib.mkIf cfg.enable {
    # For debugging and troubleshooting Secure Boot.
    environment.systemPackages = [ pkgs.sbctl ];

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    # Lanzaboote currently replaces the systemd-boot module.
    boot.loader.systemd-boot.enable = lib.mkForce false;
  };
}
