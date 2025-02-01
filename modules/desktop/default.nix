{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  imports = [
    ./gaming
    ./gnome.nix
  ];


  options.modules.desktop = {
    enable = lib.mkEnableOption "Desktop module";

    environment = {
      gnome = lib.mkEnableOption "Gnome desktop module";
    };

    gaming = {
      enable = lib.mkEnableOption "Gaming";
      streaming = lib.mkEnableOption "Enable streaming with Sunshine";
    };
  };

  # Common desktop configuration
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Terminal
      alacritty

      # Media
      jellyfin-media-player
      custom.fastflix
      obs-studio
      kdenlive
      audacity
      calibre
      mpv

      # Development
      temurin-jre-bin
      android-tools
      edge.vscode

      # Tools
      imagemagick_light
      edge.input-leap
      impression
      obsidian
      anydesk
      szyszka
      ventoy

      # Web
      qbittorrent
      firefox
      brave
      discord
    ];

    # Add support for running aarch64 binaries on x86_64
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    # Run non-nix executables
    programs.nix-ld.enable = true;

    # Add reminder for jellyfin
    warnings =
      if pkgs.jellyfin-media-player.version > "1.11.1" then
        [ "Desktop entry may be fixed https://github.com/jellyfin/jellyfin-media-player/issues/649" ]
      else [ ];

    # Setup home for desktop
    home-manager.users.${config.user.name} = {
      # Hide folders in home
      home.file = {
        ".hidden".text = ''
          Desktop
          Public
          Templates
          go
        '';
      };

      xdg = {
        enable = true;

        # Custom desktop entries
        desktopEntries = {
          "com.github.iwalton3.jellyfin-media-player" = {
            name = "Jellyfin Media Player";
            icon = "com.github.iwalton3.jellyfin-media-player";
            exec = "jellyfinmediaplayer";
            settings = {
              StartupWMClass = "jellyfinmediaplayer";
            };
            categories = [ "AudioVideo" "Video" "Player" "TV" ];
          };
        };
      };

      # Easyeffects service
      services.easyeffects.enable = true;

      # Autostart
      autostart = {
        enable = true;
        packages = [
          pkgs.discord
        ];
      };

      programs = {
        # Configure alacritty
        alacritty = {
          enable = true;
          settings = {
            window = {
              opacity = 0.9;
              dimensions = {
                columns = 140;
                lines = 40;
              };
            };
          };
        };
      };
    };

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

      # https://nixos.wiki/wiki/WireGuard#Setting_up_WireGuard_with_NetworkManager
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
        enable = true;

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
    };

    # Add zram
    # TODO: https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
    zramSwap = {
      enable = true;
      memoryPercent = 20;
    };

    # Enable scanners
    hardware.sane.enable = true;

    # Enable sound with pipewire.
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
    };

    hardware.bluetooth = {
      enable = true;
    };

    services.fwupd = {
      enable = true;
      package = pkgs.edge.fwupd;
    };

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
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      ];
      fontDir.enable = true;
      fontconfig.enable = true;
    };

    # Enable KVM
    virtualisation = {
      libvirtd.enable = true;
      spiceUSBRedirection.enable = true;
    };
    programs.virt-manager.enable = true;
  };
}
