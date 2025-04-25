{ config, ... }:
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
      environment.gnome = true;
      gaming.enable = false;
    };
  };

  # Hostname
  networking.hostName = "T14-gen3";

  # Home module settings
  home-manager.users.${config.user.name} = {
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

    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell"."favorite-apps" = [
          "org.gnome.Nautilus.desktop"
          "firefox.desktop"
          "Alacritty.desktop"
          "code.desktop"
          "obsidian.desktop"
          "discord.desktop"
          "com.github.iwalton3.jellyfin-media-player.desktop"
          "youtube-music.desktop"
        ];

        # Enable fractional scaling
        "org/gnome/mutter"."experimental-features" = [
          "scale-monitor-framebuffer"
          "xwayland-native-scaling"
        ];
      };
    };
  };

  # More info:
  # https://github.com/NixOS/nixos-hardware/tree/master/lenovo/thinkpad/t14/amd/gen3
  # https://wiki.archlinux.org/title/Lenovo_ThinkPad_T14_(AMD)_Gen_3

  boot = {
    kernelParams = [
      "acpi_backlight=native"
      "psmouse.synaptics_intertouch=0"
      "amd_pstate=active"
    ];

    # Required for tlp
    kernelModules = [ "acpi_call" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  };

  # Charge tresholds might be implemented
  # in Gnome 48 (NixOS 25.04 or higher)
  services.power-profiles-daemon.enable = false;

  # For now, use tlp
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      # Charge tresholds. (Lenovo defaults)
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Fingerprint (Synaptics [06cb:00f9])
  services.fprintd.enable = true;

  # The state version is required and should stay at the version you
  # originally installed.
  system.stateVersion = "24.05";
}
