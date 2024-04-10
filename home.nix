{ config, pkgs, ... }:
{
  imports = [
    ./editors

    ./git.nix
    ./zsh.nix
    ./overrides.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Tools
    bat
    eza
    nmap
    xclip
    kubectl

    # Development
    evans
    sqlite
    protobuf
    postgresql
    clang-tools

    # Go
    go_1_22
    air

    # Nix
    nil
    nixpkgs-fmt

    # AWS
    saml2aws
    awscli2

    # Apps
    beekeeper-studio

    # Fonts
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  xdg.enable = true;

  # Configure fonts
  fonts.fontconfig.enable = true;

  programs.tmux = {
    enable = true;
    clock24 = true;
    extraConfig = ''
      set-option -g default-shell ${pkgs.zsh}/bin/zsh
    '';
  };

  # Enable helix editor
  editors.helix.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Hide home-managers news
  news.display = "silent";

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.11";
}
