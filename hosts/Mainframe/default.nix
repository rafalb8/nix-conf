{ pkgs, ... }:
{
  imports = [
    # Include the hardware scan.
    ./hardware-configuration.nix
  ];

  # Hostname
  networking.hostName = "Mainframe";

  # Enable secure boot
  boot.loader.limine.secureBoot.enable = true;

  # Enable modules
  modules = {
    desktop.enable = true;
    gaming = { enable = true; streaming.enable = true; };
    graphics = { amd = true; overclocking.enable = true; };

    windows = {
      dualboot = true;
      disk = "guid(16f1dd3d-e30e-408d-9404-13bdd6c6951e)";
    };

    hyprland = {
      enable = true;
      wallpaper = "~/Pictures/Wallpapers/Interstellar.png";
      custom = ''
        monitorv2 {
          output = DP-1
          mode = 3440x1440@164.90
          scale = 1
          bitdepth = 10
          cm = srgb
          vrr = 2
          # SDR to HDR
          sdr_min_luminance = 0.005
          sdr_max_luminance = 200
          sdrbrightness = 1.0
          sdrsaturation = 1.0
          # HDR
          max_luminance = 430
        }
        render:cm_fs_passthrough = 2
      '';
    };
  };

  # Home module settings
  home-manager.users."rafalb8" = {
    # Git config
    programs.ssh.matchBlocks."AMDC4857" = {
      hostname = "106.120.196.83";
      user = "r.babinski";
      proxyCommand = "nc -X 5 -x 192.168.8.12:1080 %h %p";
    };

    services.easyeffects.autoload = {
      "Normalize" = [ "alsa_output.pci-0000_03_00.1.hdmi-stereo:HDMI _ DisplayPort" ];
      "Dolby Headphones" = [ "alsa_output.usb-SteelSeries_Arctis_Nova_7-00.analog-stereo:Analog Output" ];
    };
  };

  # Additional packages
  services.flatpak.enable = true;
  environment.systemPackages = with pkgs; [ oversteer custom.tsmuxer ];

  # Steering wheel support
  hardware.new-lg4ff.enable = true;
  services.udev.packages = with pkgs; [ oversteer rpcs3 ];

  hardware.logitech.wireless.enable = true;
  # The state version is required and should stay at the version you
  # originally installed.
  system.stateVersion = "24.11";
}
