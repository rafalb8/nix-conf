{pkgs, lib, ...}:
{
  options = {
    programs.fastflix = {
      enable = lib.mkEnableOption "FastFlix";
      package = 
    }
  };
}