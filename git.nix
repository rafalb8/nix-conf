{ config, pkgs, ... }:
{
  # Setup git
  programs.git = {
    enable = true;

    aliases = {
      s = "status";
      b = "branch -avv";
      f = "fetch --all --prune";
      cb = "checkout -b";
      co = "checkout";
      l = "log";
      lo = "log --oneline";
      lg = "log --graph";
      log-graph = "log --graph --all --oneline --decorate";
      sps = "!git stash && git pull && git stash pop";
    };
  };
}
