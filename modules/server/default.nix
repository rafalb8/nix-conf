{ config, pkgs, lib, ... }:
let
  cfg = config.modules.server;
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

    # Enable Tailscale `--advertise-exit-node` feature
    services.tailscale.useRoutingFeatures = "server";

    # Add "motd" with ZFS status
    home-manager.users.${config.user.name} = {
      programs.zsh.initContent = ''
        zpool status -x
      '';
    };
  };
}
