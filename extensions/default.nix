{ config, pkgs, lib, ... }:
{
  imports = [
    ./options.nix

    ./programs/helix
  ];
}
