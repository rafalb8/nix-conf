{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  imports = [
    ./gaming.nix
    ./gnome.nix
  ];

  options.modules.desktop = {
    enable = lib.mkEnableOption "Desktop module";

    enviroment = {
      gnome = lib.mkEnableOption "Gnome desktop module";
    };

    gaming = {
      enable = lib.mkEnableOption "Gaming";
    };
  };

  # Common desktop configuration
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Media
      jellyfin-media-player
      obs-studio
      kdenlive
      audacity
      calibre
      mpv

      # Development
      temurin-jre-bin
      alacritty
      vscode

      # Tools
      imagemagick_light
      impression
      obsidian
      anydesk
      barrier
      szyszka
      ventoy

      # Web
      qbittorrent
      firefox
      discord
    ];

    # Add support for running aarch64 binaries on x86_64
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    # Run non-nix executables
    programs.nix-ld.enable = true;

    # Setup home for desktop
    home-manager.users.${config.user.name} = {
      imports = [
        ../home/autostart.nix
      ];

      xdg = {
        enable = true;
        configFile = {
          # Solaar (Logitech)
          "solaar" = {
            source = ../../dotfiles/solaar;
            recursive = true;
          };

          # Easyeffects
          "easyeffects" = {
            source = ../../dotfiles/easyeffects;
            recursive = true;
          };
        };

        # Custom desktop entries
        desktopEntries = {
          solaar = {
            name = "Solaar";
            icon = "solaar";
            exec = "solaar -w hide";
            terminal = false;
            categories = [ "Utility" "GTK" ];
          };
        };
      };

      # Easyeffects service
      services.easyeffects.enable = true;

      # Autostart
      autostart = {
        enable = true;
        packages = [
          pkgs.solaar
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

        # SSH config
        ssh = {
          enable = true;
          extraConfig = ''
            Host server
              HostName 192.168.0.100
          '';
        };
      };
    };

    # Firewall
    networking.firewall = {
      enable = true;
      ports = [
        # Barrier
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
      flatpak.enable = true;
    };

    # Enable scanners
    hardware.sane.enable = true;

    # Add solaar
    hardware.logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

    # Enable sound with pipewire.
    sound.enable = true;
    hardware.pulseaudio.enable = false;
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

    # Fonts
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        noto-fonts-monochrome-emoji
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      ];
      fontDir.enable = true;
      fontconfig.enable = true;
    };

    # Fix fonts for flatpaks
    # https://nixos.wiki/wiki/Fonts#Using_bindfs_for_font_support
    system.fsPackages = [ pkgs.bindfs ];
    fileSystems =
      let
        mkRoSymBind = path: {
          device = path;
          fsType = "fuse.bindfs";
          options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
        };
        aggregatedIcons = pkgs.buildEnv
          {
            name = "system-icons";
            paths = with pkgs; [
              #libsForQt5.breeze-qt5  # for plasma
              gnome.gnome-themes-extra
            ];
            pathsToLink = [ "/share/icons" ];
          };
        aggregatedFonts = pkgs.buildEnv
          {
            name = "system-fonts";
            paths = config.fonts.packages;
            pathsToLink = [ "/share/fonts" ];
          };
      in
      {
        "/usr/share/icons" = mkRoSymBind "${aggregatedIcons}/share/icons";
        "/usr/local/share/fonts" = mkRoSymBind "${aggregatedFonts}/share/fonts";
      };

    # Enable KVM
    virtualisation = {
      libvirtd.enable = true;
      spiceUSBRedirection.enable = true;
    };
    programs.virt-manager.enable = true;
  };
}
