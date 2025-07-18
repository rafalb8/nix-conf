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

    # Disable waydroid-container.service
    systemd.services.waydroid-container.wantedBy = lib.mkForce [ ];

    # sudo waydroid-script -> Android 11 >> Install ...
    environment.systemPackages = with pkgs; [ custom.waydroid_script ];
  };
}
