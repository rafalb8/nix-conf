{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
  autostart = import ../functions/autostart.nix config;
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
      # Media
      jellyfin-media-player
      easyeffects
      calibre
      mpv

      # Development
      temurin-jre-bin
      alacritty
      vscode

      # Tools
      # obsidian
      anydesk
      barrier
      szyszka
      ventoy

      # Gaming
      protontricks
      mangohud
      bottles
      steam

      # Web
      qbittorrent
      firefox
      discord
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

        # Custom desktop entries
        desktopEntries = {
          steam = {
            name = "Steam";
            icon = "steam";
            exec = "env MANGOHUD=1 steam -silent %U";
            terminal = false;
            categories = [ "Network" "FileTransfer" "Game" ];
            mimeType = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ];
            actions = {
              "Store" = { exec = "steam steam://store"; };
              "Library" = { exec = "steam steam://open/games"; };
              "Friends" = { exec = "steam steam://open/friends"; };
              "Settings" = { exec = "steam steam://open/settings"; };
              "BigPicture" = {
                name = "Big Picture";
                exec = "steam steam://open/bigpicture";
              };
            };
          };

          solaar = {
            name = "Solaar";
            icon = "solaar";
            exec = "solaar -w hide";
            terminal = false;
            categories = [ "Utility" "GTK" ];
          };

          "com.github.wwmm.easyeffects" = {
            name = "Easy Effects";
            icon = "com.github.wwmm.easyeffects";
            exec = "easyeffects -w";
            terminal = false;
            categories = [ "GTK" "AudioVideo" "Audio" ];
          };
        };
      };

      # Autostart
      home.file = autostart [
        pkgs.steam
        pkgs.discord
        pkgs.solaar
        (pkgs.easyeffects // { pname = "com.github.wwmm.easyeffects"; })
      ];

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
    networking.firewall =
      let
        ports = [
          # Barrier
          24800
        ];
        portRanges = [
          # KDE Connect
          { from = 1714; to = 1764; }
        ];
      in
      {
        allowedTCPPorts = ports;
        allowedUDPPorts = ports;
        allowedTCPPortRanges = portRanges;
        allowedUDPPortRanges = portRanges;
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
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
    programs.virt-manager.enable = true;
  };
}
