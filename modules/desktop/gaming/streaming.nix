{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;

  sunshine = pkgs.edge.sunshine.overrideAttrs (oldAttrs: rec {
    version = "2024.922.10353";
    src = pkgs.fetchFromGitHub {
      owner = "LizardByte";
      repo = "Sunshine";
      rev = "v${version}";
      sha256 = lib.fakeSha256;
    };
  });
in
{
  config = lib.mkIf (cfg.gaming.enable && cfg.gaming.streaming) {
    services.sunshine = {
      enable = true;
      autoStart = false;
      openFirewall = true;

      package = (sunshine.override { cudaSupport = true; });
    };
  };
}
