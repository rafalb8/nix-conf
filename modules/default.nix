{ lib, pkgs, ... }:
{
  # Modules
  imports = [
    ./desktop
    ./graphics
    ./server
    ./user

    ./packages.nix
    ./secureboot.nix
  ];

  # Use latest kernel
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;

  # Bootloader
  boot.loader = {
    timeout = 0;
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable fstrim for SSD
  services.fstrim.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Enable zram
  zramSwap = {
    enable = true;
    memoryPercent = 20;
  };
  # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

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
  console.keyMap = "pl";

  environment.shellAliases =
    let
      nix-ext = pkgs.writeShellScriptBin "nix-ext" ''
        DIR="/etc/nixos"
        CMD="$1"
        shift
        case $CMD in
          pull) cd $DIR; git pull;;
          apply) nixos-rebuild switch --show-trace -L -v "$@";;
          boot) nixos-rebuild boot --show-trace -L -v "$@";;
          upgrade) eval '\nix flake update --flake $DIR && nixos-rebuild boot --show-trace -L -v "$@"';;
          config) code $DIR "$@";;
          *) \nix $CMD "$@";;
        esac
      '';
    in
    {
      # Enable sudo with aliases
      sudo = "sudo ";

      # Main
      du = "du -h";
      df = "df -h";
      xclip = "xclip -selection clipboard";
      fgkill = "jobs -p | grep -o -E ' [0-9]+ ' | xargs -r -n1 pkill -SIGINT -g";
      certcat = "openssl x509 -text -in";
      rsync-cp = "rsync -a --info=progress2 --no-i-r";

      # Nix extension
      nix = "${nix-ext}/bin/nix-ext";

      # Replacements
      cat = "bat";
      ls = "eza";

      # ls
      ll = "ls -lh"; # list
      la = "ls -lah"; # all files list
    };

  # Nix config
  nix = {
    # Enable nix-command and flakes
    settings.experimental-features = [ "nix-command" "flakes" ];

    # Perform garbage collection weekly to maintain low disk usage
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    # Nix automatically detects files in the store that have identical contents,
    # and replaces them with hard links to a single copy.
    settings.auto-optimise-store = true;
  };

  # Run non-nix executables
  programs.nix-ld.enable = true;
}
