{ lib, pkgs, ... }:
{
  # Modules
  imports = [
    ./desktop
    ./graphics
    ./server
    ./user

    ./packages.nix
  ];

  # Use latest kernel
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;

  # Bootloader
  boot.loader = {
    timeout = 1;

    # Secure Boot TLDR:
    # Instructions: https://wiki.nixos.org/wiki/Limine
    # [firmware]: Enable Secure Boot => "Reset to Setup Mode" or just remove PK keys
    # [os]: sudo sbctl create-keys
    # [os]: sudo sbctl enroll-keys -m -f
    # If fails: sudo chattr -i (files printed in sbctl enroll-keys) => repeat enroll-keys
    # [nix]: boot.loader.limine.secureBoot.enable = true; => rebuild
    # reboot
    # bootctl status
    limine = {
      enable = true;
      maxGenerations = 10;
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
        if (( EUID == 0 )); then
          echo "\e[1;91mAvoid running nix as root/sudo."
        fi

        DIR="/etc/nixos"
        CMD="$1"
        shift
        case $CMD in
          pull) cd $DIR; git pull;;
          apply) sudo true && nixos-rebuild switch --sudo -Lv "$@";;
          boot) sudo true && nixos-rebuild boot --sudo -Lv "$@";;
          upgrade)
              sudo true # Cache password
              cd $DIR
              \nix flake update
              git add flake.lock && git commit -m "Bump [$(date --rfc-3339=date)]"
              nixos-rebuild boot --sudo -Lv "$@";;
          code) zeditor $DIR "$@";;
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

    settings.download-buffer-size = 524288000; # 500M

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
