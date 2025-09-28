{ pkgs, ... }:
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search nixpkgs wget
  environment.systemPackages = with pkgs; [
    # Tools
    # appimage-run
    hydra-check
    ripgrep
    xclip
    file
    lsof
    bat
    eza
    fzf
    fd

    # Editors
    vim
    micro

    # System
    exfatprogs
    efibootmgr
    dmidecode
    pciutils
    usbutils
    btop

    # Networking
    nmap
    wget
    rsync
    rclone
    arp-scan

    # Archivers
    p7zip
    lz4

    # Media
    ffmpeg-full
    yt-dlp

    # Development
    jq
    gcc
    gnumake

    # Golang
    go
    air
    gopls
    delve
    gofumpt

    # Nix
    nil
    nixpkgs-fmt
  ];

  programs = {
    git.enable = true;
    zsh.enable = true;
    appimage = {
      enable = true;
      binfmt = true;
    };
  };

  services.tailscale.enable = true;
  virtualisation.docker.enable = true;
}
