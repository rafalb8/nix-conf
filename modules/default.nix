{ config, lib, pkgs, ... }:
{
  # Modules
  imports = [
    ../extensions/options.nix

    ./desktop
    ./graphics
    ./home
  ];

  # Base

  boot = {
    # Use latest kernel
    kernelPackages = pkgs.linuxPackages_latest;

    # Bootloader
    loader = {
      timeout = 0;
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pl_PL.UTF-8";
      LC_IDENTIFICATION = "pl_PL.UTF-8";
      LC_MEASUREMENT = "pl_PL.UTF-8";
      LC_MONETARY = "pl_PL.UTF-8";
      LC_NAME = "pl_PL.UTF-8";
      LC_NUMERIC = "pl_PL.UTF-8";
      LC_PAPER = "pl_PL.UTF-8";
      LC_TELEPHONE = "pl_PL.UTF-8";
      LC_TIME = "pl_PL.UTF-8";
    };
  };

  # Configure console keymap
  console.keyMap = "pl2";

  # Define a user account.
  users.users.${config.username} = {
    isNormalUser = true;
    description = "Rafal Babinski";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" ];
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Tools
    appimage-run
    ripgrep
    xclip
    file
    lsof
    bat
    eza
    fd

    # System
    efibootmgr
    usbutils
    btop

    # Networking
    nmap
    wget
    rsync
    arp-scan

    # Filesystems
    exfatprogs

    # Archivers
    p7zip
    lz4

    # Media
    ffmpeg
    yt-dlp

    # Development
    rnix-lsp
    gnumake
    gcc
    jq
    go
  ];

  programs = {
    git.enable = true;
    zsh.enable = true;
  };

  # List services that you want to enable:
  services.zerotierone.enable = true;

  # Docker
  virtualisation.docker.enable = true;
  systemd.services.docker.wantedBy = lib.mkForce [ ];
}
