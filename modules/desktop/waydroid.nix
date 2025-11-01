{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop;
in
{
  # https://wiki.nixos.org/wiki/Waydroid
  # ---

  # To initialize the Waydroid container, run:
  #   sudo waydroid init

  # Start the container with:
  #   sudo systemctl start waydroid-container

  # Start the session with:
  #   waydroid session start

  # To reset
  #   sudo rm -rf /var/lib/waydroid ~/.local/share/waydroid

  # ---

  config = lib.mkIf cfg.waydroid {
    virtualisation.waydroid.enable = true;
    environment.systemPackages = with pkgs; [ waydroid-helper ];

    # Disable waydroid-container.service
    systemd.services.waydroid-container.wantedBy = lib.mkForce [ ];
  };
}
