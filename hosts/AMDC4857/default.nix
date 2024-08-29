{ config, pkgs, ... }:
{
  imports = [ ./zsh.nix ];

  nixpkgs.config.allowUnfree = true;
  nix = {
    # Perform garbage collection weekly to maintain low disk usage
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };

  home.packages = with pkgs; [
    # Tools
    bat
    eza
    nmap
    xclip
    ripgrep
    kubectl

    # Development
    evans
    protobuf
    clang-tools

    # DB
    sqlite
    postgresql
    beekeeper-studio

    # Go
    # go_1_22
    go
    air
    gofumpt

    # Deps
    graphviz-nox

    # Nix
    nil
    nixpkgs-fmt

    # AWS
    saml2aws
    awscli2

    # Apps
    # obsidian

    # Fonts
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # Setup git
  programs.git = {
    enable = true;
    userName = "Rafal Babinski";

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

  # Configure fonts
  fonts.fontconfig.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Hide home-managers news
  news.display = "silent";

  home.username = "r.babinski";
  home.homeDirectory = "/home/r.babinski";

  # The state version should stay at the version you originally installed.
  home.stateVersion = "23.11";
}
