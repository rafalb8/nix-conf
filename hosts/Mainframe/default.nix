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

  # Disable IPv6
  networking.enableIPv6 = false;

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
      wallpaper = toString (pkgs.fetchurl {
        # https://www.reddit.com/r/WidescreenWallpaper/comments/1uzneby/golden_gate_at_dusk_5120x2160
        url = "https://i.redd.it/5sgzlnurexdh1.png";
        # nix-prefetch-url {url}
        sha256 = "1ak621w9llcmpr4p4vzrgfifn098aj785f29hx3c6r4paqp1ds93";
      });
      custom = ''
        hl.monitor({
            output = "DP-1",
            mode = "3440x1440@164.90",
            position = "auto",
            scale = 1,
            bitdepth = 10,
            cm = "srgb",
            vrr = 2,
            -- SDR to HDR
            sdr_min_luminance = 0.005,
            sdr_max_luminance = 200,
            sdrbrightness = 1.0,
            sdrsaturation = 1.0,
            -- HDR
            max_luminance = 430,
        })
        hl.config({render = {cm_auto_hdr = 1}})
      '';
    };
  };

  # Additional packages
  # services.flatpak.enable = true;
  environment.systemPackages = with pkgs; [
    slack
    qFlipper
    oversteer
    custom.tsmuxer
    custom.audio-offset-finder
  ];

  # Hardware
  hardware.new-lg4ff.enable = true;
  hardware.logitech.wireless.enable = true;
  services.udev.packages = with pkgs; [ oversteer qFlipper ];

  # Home module settings
  home-manager.users."rafalb8" = {
    # Git config
    programs.ssh.settings."AMDC4857" = {
      Hostname = "106.120.196.83";
      User = "r.babinski";
      ProxyCommand = "nc -X 5 -x 192.168.8.12:1080 %h %p";
    };

    services.easyeffects.autoload = {
      "Normalize" = [ "alsa_output.pci-0000_03_00.1.hdmi-stereo:HDMI _ DisplayPort" ];
      "Dolby Headphones" = [ "alsa_output.usb-SteelSeries_Arctis_Nova_7-00.analog-stereo:Analog Output" ];
    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  system.stateVersion = "24.11";
}
