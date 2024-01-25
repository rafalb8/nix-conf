{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  imports = [
    ./gnome.nix
  ];

  options.modules.desktop = {
    enable = lib.mkEnableOption "Desktop module";

    enviroment = {
      gnome = lib.mkEnableOption "Gnome desktop module";
    };
  };

  # Common desktop configuration
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Media tools
      easyeffects
      calibre
      mpv

      # Development
      temurin-jre-bin
      alacritty
      vscode

      # Other
      ventoy
      barrier
      szyszka
      qbittorrent
    ];

    # Setup home for desktop
    home-manager.users.rafalb8 = {
      xdg = {
        enable = true;
        configFile = {
          # Configure MangoHud
          "MangoHud" = {
            source = ../../dotfiles/MangoHud;
            recursive = true;
          };

          # Solaar (Logitech)
          "solaar" = {
            source = ../../dotfiles/solaar;
            recursive = true;
          };
        };
      };

      # Configure alacritty
      programs.alacritty = {
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

    networking = {
      firewall = {
        allowedTCPPorts = [
          # Barrier
          24800
        ];

        allowedUDPPorts = [
          # Barrier
          24800
        ];

        allowedTCPPortRanges = [
          # KDE Connect
          { from = 1714; to = 1764; }
        ];

        allowedUDPPortRanges = [
          # KDE Connect
          { from = 1714; to = 1764; }
        ];
      };
    };

    # Setup desktop services
    services = {
      xserver = {
        enable = true;

        # Configure keymap in X11
        layout = "pl";
        xkbVariant = "";
      };

      flatpak.enable = true;
      printing.enable = true;
    };

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
      fontDir.enable = true;
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        liberation_ttf
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      ];
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
        aggregatedIcons = pkgs.buildEnv {
          name = "system-icons";
          paths = with pkgs; [
            #libsForQt5.breeze-qt5  # for plasma
            gnome.gnome-themes-extra
          ];
          pathsToLink = [ "/share/icons" ];
        };
        aggregatedFonts = pkgs.buildEnv {
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
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
    programs.virt-manager.enable = true;
  };
}
