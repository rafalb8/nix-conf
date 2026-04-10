{ pkgs, lib, ... }:
{
  imports = lib.custom.importAll ./.;

  # Nix config
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    settings.experimental-features = [ "nix-command" "flakes" ];
    settings.download-buffer-size = 524288000; # 500M
    settings.auto-optimise-store = true;
  };

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

  # Trim SSDs
  services.fstrim.enable = true;

  # Select internationalisation properties.
  console.keyMap = "pl";
  time.timeZone = "Europe/Warsaw";
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

  # Raise memlock limits
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "memlock";
      value = "unlimited";
    }
    {
      domain = "*";
      type = "hard";
      item = "memlock";
      value = "unlimited";
    }
  ];

  # Enable networking
  networking.networkmanager.enable = true;
}
