{ config, lib, pkgs, ... }:
{
  options = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "System username";
    };
  };
}
