{ config, pkgs, ... }:
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

    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell"."favorite-apps" = [
          "org.gnome.Nautilus.desktop"
          "firefox.desktop"
          "Alacritty.desktop"
          "code.desktop"
          "discord.desktop"
          "com.github.iwalton3.jellyfin-media-player.desktop"
        ];

        "org/gnome/shell/extensions/dash-to-panel" =
          let
            mkPanelConfig = screen: {
              panel-anchors = { "${screen}" = "MIDDLE"; };
              panel-lengths = { "${screen}" = 100; };
              panel-sizes = { "${screen}" = 48; };
              panel-element-positions = {
                "${screen}" = [
                  { "element" = "showAppsButton"; "visible" = false; "position" = "stackedTL"; }
                  { "element" = "activitiesButton"; "visible" = false; "position" = "stackedTL"; }
                  { "element" = "leftBox"; "visible" = true; "position" = "stackedTL"; }
                  { "element" = "taskbar"; "visible" = true; "position" = "centerMonitor"; }
                  { "element" = "centerBox"; "visible" = true; "position" = "stackedBR"; }
                  { "element" = "rightBox"; "visible" = true; "position" = "stackedBR"; }
                  { "element" = "dateMenu"; "visible" = true; "position" = "stackedBR"; }
                  { "element" = "systemMenu"; "visible" = true; "position" = "stackedBR"; }
                  { "element" = "desktopButton"; "visible" = true; "position" = "stackedBR"; }
                ];
              };
            };

            tv = mkPanelConfig "XXX-0x00010000";
            monitor = mkPanelConfig "LEN-0x00000000";

            mkConfig = cfgs: with builtins; {
              panel-anchors = toJSON (foldl' (acc: cfg: acc // cfg.panel-anchors) { } cfgs);
              panel-lengths = toJSON (foldl' (acc: cfg: acc // cfg.panel-lengths) { } cfgs);
              panel-sizes = toJSON (foldl' (acc: cfg: acc // cfg.panel-sizes) { } cfgs);
              panel-element-positions = toJSON (foldl' (acc: cfg: acc // cfg.panel-element-positions) { } cfgs);
            };
          in
          {
            intellihide = false;
            appicon-margin = 8;
            appicon-padding = 4;
            trans-use-custom-opacity = true;
            trans-use-dynamic-opacity = false;
            trans-use-custom-gradient = false;
            stockgs-keep-top-panel = false;
            stockgs-keep-dash = false;
            show-window-previews = true;
            isolate-workspaces = true;
            panel-element-positions-monitors-sync = true;
            panel-positions = ''{}'';
          } // (mkConfig [ monitor tv ]);

        "org/gnome/shell/extensions/arcmenu" = {
          custom-menu-button-icon-size = 42.0;
          pinned-apps = with lib.hm.gvariant; [
            [ (mkDictionaryEntry [ "id" "com.github.th_ch.youtube_music.desktop" ]) ]
            [ (mkDictionaryEntry [ "id" "com.github.wwmm.easyeffects.desktop" ]) ]
            [ (mkDictionaryEntry [ "id" "obsidian.desktop" ]) ]
          ];
        };

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
