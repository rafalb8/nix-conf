{ lib, ... }:
{
  imports = [
    # Include the hardware scan.
    ./hardware-configuration.nix
  ];

  # Hostname
  networking.hostName = "T14-gen3";

  # Enable secure boot
  boot.loader.limine.secureBoot.enable = true;

  # Enable modules
  modules = {
    graphics.amd = true;
    desktop.enable = true;
    windows.dualboot = true;
    hyprland = {
      enable = true;
      wallpaper = "~/Pictures/Wallpapers/1.jpg";
      custom = ''
        monitor = eDP-1, preferred, auto, 1
      '';
    };
  };

  # Additional packages
  # environment.systemPackages = with pkgs; [ ];

  # Home module settings
  home-manager.users."rafalb8" = {
    services.easyeffects = {
      presets = [ "Dolby Dynamic" ];
      autoload = {
        "Dolby Headphones" = [ "alsa_output.pci-0000_04_00.6.HiFi__Headphones__sink:Headphones" ];
        "Dolby Dynamic" = [ "alsa_output.pci-0000_04_00.6.HiFi__Speaker__sink:Speaker" ];
      };
    };
  };

  # More info:
  # https://github.com/NixOS/nixos-hardware/tree/master/lenovo/thinkpad/t14/amd/gen3
  # https://wiki.archlinux.org/title/Lenovo_ThinkPad_T14_(AMD)_Gen_3

  boot.kernelParams = [
    "acpi_backlight=native"
    "psmouse.synaptics_intertouch=0"
    "amd_pstate=active"
    # MediaTek wifi fix
    # "mt7921_common.disable_clc=1"
  ];

  # Fingerprint (Synaptics [06cb:00f9])
  services.fprintd.enable = true;

  # Allow TZ to be set by user
  time.timeZone = lib.mkForce null;

  # The state version is required and should stay at the version you
  # originally installed.
  system.stateVersion = "24.05";
}
