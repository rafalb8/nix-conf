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
      nix-alias = pkgs.writeShellScriptBin "nix-alias" ''
        cmd="$1"
        shift
        case $cmd in
          apply) nixos-rebuild switch --show-trace -L -v "$@";;
          boot) nixos-rebuild boot --show-trace -L -v "$@";;
          upgrade) eval '\nix flake update --flake /etc/nixos && nixos-rebuild boot --show-trace -L -v "$@"';;
          config) code /etc/nixos "$@";;
          *) \nix $cmd "$@";;
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

      # NixOS aliases
      nix = "${nix-alias}/bin/nix-alias";

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
