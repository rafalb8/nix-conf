{ config, lib, pkgs, ... }:
{
  # Modules
  imports = [
    ../extensions

    ./desktop
    ./graphics
    ./home
  ];

  # Base

  boot = {
    # Use latest kernel
    kernelPackages = pkgs.edge.linuxPackages_latest;

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
  nixpkgs.config = {
    allowUnfree = true;
  };

  nix = {
    # Enable nix-command and flakes
    settings.experimental-features = [ "nix-command" "flakes" ];

    # Perform garbage collection weekly to maintain low disk usage
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    # Nix automatically detects files in the store that have identical contents,
    # and replaces them with hard links to a single copy.
    settings.auto-optimise-store = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" "pl_PL.UTF-8/UTF-8" ];
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
  users.users.${config.user.name} = {
    isNormalUser = true;
    description = config.user.description;
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "input" ];
    shell = pkgs.zsh;
  };

  environment.shellAliases = {
    # Enable sudo with aliases
    sudo = "sudo ";

    # Main
    du = "du -h";
    df = "df -h";
    xclip = "xclip -selection clipboard";
    fgkill = "jobs -p | grep -o -E ' [0-9]+ ' | xargs -r -n1 pkill -SIGINT -g";
    certcat = "openssl x509 -text -in";
    rsync-cp = "rsync -a --info=progress2 --no-i-r";

    # NixOS aliases
    nix-apply = "nixos-rebuild switch --show-trace -L -v";
    nix-upgrade = "eval 'nix flake update /etc/nixos && nixos-rebuild boot --show-trace -L -v'";
    nix-edit = "code /etc/nixos";

    # Replacements
    cat = "bat";
    ls = "eza";

    # ls
    ll = "ls -lh"; # list
    la = "ls -lah"; # all files list
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
    vim
    fd

    # System
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

    # Filesystems
    exfatprogs

    # Archivers
    p7zip
    lz4

    # Media
    ffmpeg-full
    yt-dlp

    # Development
    gnumake
    gcc
    jq

    # Golang
    go
    gopls
    delve
    air

    # Nix
    nil
    nixpkgs-fmt

    # Rust
    rustup
    rust-analyzer
  ];

  programs = {
    git.enable = true;
    zsh.enable = true;
  };

  services.tailscale = {
    enable = true;
    package = pkgs.edge.tailscale;
  };

  # Docker
  virtualisation.docker.enable = true;
  systemd.services.docker.wantedBy = lib.mkForce [ ];

  # Enable fstrim for SSD
  services.fstrim.enable = true;
}
