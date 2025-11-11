{ config, pkgs, lib, ... }:
let
  cfg = config.modules.secureboot;
in
{
  # Instructions: https://wiki.nixos.org/wiki/Limine
  # TLDR:
  # sudo nix run nixpkgs#sbctl -- create-keys
  # [nix]: modules.secureboot.enable = true; => rebuild
  # sudo sbctl verify
  # [firmware]: Enable Secure Boot => "Reset to Setup Mode" or just remove PK keys
  # sudo sbctl enroll-keys -m -f
  # If fails: sudo chattr -i (files printed in sbctl enroll-keys) => repeat enroll-keys
  # reboot
  # bootctl status

  options.modules.secureboot = {
    enable = lib.mkEnableOption "Enable Secure Boot in limine";
  };

  config = lib.mkIf cfg.enable {
    # For debugging and troubleshooting Secure Boot.
    environment.systemPackages = [ pkgs.sbctl ];

    boot.loader.limine.secureBoot.enable = true;
  };
}
