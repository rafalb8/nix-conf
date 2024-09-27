{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf (cfg.gaming.enable && cfg.gaming.streaming) {
    services.sunshine = {
      enable = true;
      autoStart = false;
      openFirewall = true;

      package = (pkgs.edge.sunshine.override {
        cudaSupport = true;
      });
    };
  };
}
