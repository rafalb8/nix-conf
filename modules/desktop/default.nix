{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  imports = [
    ./gaming

    ./gnome.nix
    ./hyprland

    ./browsers.nix
    ./packages.nix
    ./waydroid.nix
    ./graphical-boot.nix
  ];

  options.modules.desktop = {
    enable = lib.mkEnableOption "Desktop module";

    graphicalBoot = lib.mkEnableOption "Enable graphical boot";

    waydroid = lib.mkEnableOption "Waydroid support";

    environment = {
      gnome = lib.mkEnableOption "Gnome desktop module";
      hyprland = lib.mkEnableOption "Hyprland desktop module";
    };

    gaming = {
      enable = lib.mkEnableOption "Gaming";
      streaming = lib.mkEnableOption "Enable streaming with Sunshine";
    };
  };

  # Common desktop configuration
  config = lib.mkIf cfg.enable {
    # Add support for running aarch64 binaries on x86_64
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    # Disable NetworkManager-wait-online.service 
    systemd.services.NetworkManager-wait-online.enable = false;

    # Use iwd as NetworkManager backend
    networking.wireless.iwd.enable = true;
    networking.networkmanager.wifi.backend = "iwd";

    # Firewall
    networking.firewall = {
      enable = true;
      ports = [
        # Barrier / Input-Leap
        "24800"
        # Wireguard
        "51820/udp"
        # KDE Connect
        "1714-1764"
      ];

      # https://wiki.nixos.org/wiki/WireGuard#Setting_up_WireGuard_with_NetworkManager
      extraCommands = ''
        ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
        ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
      '';
      extraStopCommands = ''
        ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
        ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
      '';
    };

    # Setup desktop services
    services = {
      xserver = {
        # Configure keymap in X11
        xkb = {
          layout = "pl";
          variant = "";
        };
      };

      printing = {
        enable = true;
        drivers = with pkgs; [ splix ];
      };

      udisks2.enable = true;

      # Auto nice deamon
      ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };
    };

    services.fwupd.enable = true;
    hardware = {
      bluetooth.enable = true;
      sane.enable = true; # Scanners
    };

    # Enable sound with pipewire.
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
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

    # Fonts
    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        noto-fonts-monochrome-emoji
        source-code-pro
        source-han-mono
        source-han-sans
        source-han-serif
        nerd-fonts.jetbrains-mono
      ];
      fontDir.enable = true;
      fontconfig.enable = true;
    };

    # Setup home for desktop
    home-manager.users.${config.user.name} = {
      # Hide folders in home
      home.file.".hidden".text = ''
        Desktop
        Public
        Templates
        go
      '';

      # Required
      xdg.enable = true;

      # Fix for jellyfin
      xdg.desktopEntries."com.github.iwalton3.jellyfin-media-player" = {
        name = "Jellyfin Media Player";
        icon = "com.github.iwalton3.jellyfin-media-player";
        exec = "jellyfinmediaplayer";
        settings = {
          StartupWMClass = "jellyfinmediaplayer";
        };
        categories = [ "AudioVideo" "Video" "Player" "TV" ];
      };

      # Enable Wayland HDR for Jellyfin MPV Shim and MPV
      xdg.configFile = {
        "mpv/mpv.conf".text = ''vo=dmabuf-wayland'';
        "jellyfin-mpv-shim/mpv.conf".text = ''vo=dmabuf-wayland'';
      };

      # Easyeffects service
      services.easyeffects = {
        enable = true;
        presets = [ "Clean" "Normalize" "Dolby Headphones" ];
      };

      # Autostart
      autostart = {
        enable = true;
        packages = [ pkgs.discord ];
      };

      # Configure alacritty
      programs.alacritty = {
        enable = true;
        settings.window = {
          opacity = 0.9;
          dimensions = {
            columns = 140;
            lines = 40;
          };
        };
      };
    };

    # Enable KVM
    virtualisation = {
      libvirtd.enable = true;
      spiceUSBRedirection.enable = true;
    };
    programs.virt-manager.enable = true;

    # Disable Docker on boot
    systemd.services.docker.wantedBy = lib.mkForce [ ];
  };
}
