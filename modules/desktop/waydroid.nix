{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop;
in
{
  # https://wiki.nixos.org/wiki/Waydroid
  # ---
  
  # To initialize the Waydroid container, run:
  #   sudo waydroid init -s GAPPS -f

  # Start the container with:
  #   sudo systemctl start waydroid-container

  # Start the session with:
  #   waydroid session start

  # ---

  config = lib.mkIf cfg.waydroid {
    virtualisation.waydroid.enable = true;

    # Disable waydroid-container.service
    systemd.services.waydroid-container.wantedBy = lib.mkForce [ ];

    # Run arm64 binaries on x86_64
    # sudo waydroid-script -> Android 11 >> Install >> libhoudini
    environment.systemPackages = with pkgs; [ nur.repos.ataraxiasjel.waydroid-script ];
  };
}
