{ config, pkgs, lib, ... }:
{
  imports = [
    # Include the hardware scan.
    ./hardware-configuration.nix
  ];

  user = {
    name = "rafalb8";
    description = "Rafal Babinski";
  };

  # Enable modules
  modules = {
    graphics.amd = true;

    desktop = {
      enable = true;
      graphicalBoot = true;
      environment.gnome = true;
      gaming.enable = false;
    };
  };

  # Hostname
  networking.hostName = "T14-gen3";

  # Additional packages 
  environment.systemPackages = with pkgs; [ moonlight-qt ];

  # Home module settings
  home-manager.users.${config.user.name} = { lib, ... }: {
    # Git config
    programs.git = {
      userName = "Rafalb8";
      userEmail = "rafalb8@hotmail.com";
    };

    services.easyeffects = {
      presets = [ "Dolby Dynamic" ];
      autoload = {
        "Dolby Headphones" = [ "alsa_output.pci-0000_04_00.6.HiFi__Headphones__sink:[Out] Headphones" ];
        "Dolby Dynamic" = [ "alsa_output.pci-0000_04_00.6.HiFi__Speaker__sink:[Out] Speaker" ];
      };
    };

    dconf.enable = true;
    dconf.settings."org/gnome/shell"."favorite-apps" = [
      "org.gnome.Nautilus.desktop"
      "firefox.desktop"
      "Alacritty.desktop"
      "code.desktop"
      "discord.desktop"
      "com.github.iwalton3.jellyfin-media-player.desktop"
    ];
  };

  # More info:
  # https://github.com/NixOS/nixos-hardware/tree/master/lenovo/thinkpad/t14/amd/gen3
  # https://wiki.archlinux.org/title/Lenovo_ThinkPad_T14_(AMD)_Gen_3

  boot.kernelParams = [
    "acpi_backlight=native"
    "psmouse.synaptics_intertouch=0"
    "amd_pstate=active"
  ];

  # Fingerprint (Synaptics [06cb:00f9])
  services.fprintd.enable = true;

  # MediaTek wifi fix
  warnings = lib.optional (pkgs.linux-firmware.version > "20250917")
    ''MediaTek wifi might be fixed'';
  hardware.firmware =
    let
      nixpkgs = pkgs.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "00b574b1ba8a352f0601c4dde4faff4b534ebb1e";
        hash = "sha256-WrZ280bT6NzNbBo+CKeJA/NW1rhvN/RUPZczqCpu2mI=";
      };
    in
    [ (import nixpkgs { inherit (pkgs) system; }).linux-firmware ];

  # The state version is required and should stay at the version you
  # originally installed.
  system.stateVersion = "24.05";
}
