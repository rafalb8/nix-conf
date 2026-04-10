{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  imports = lib.custom.importAll ./.;

  options.modules.desktop = {
    enable = lib.mkEnableOption "Desktop module";
  };

  # Common desktop configuration
  config = lib.mkIf cfg.enable {
    # Enable boot splash screen
    boot.plymouth.enable = true;

    # Enable "Silent boot"
    boot.consoleLogLevel = 3;
    boot.initrd.verbose = false;
    boot.kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];

    # Enable tailscale
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };

    # Disable NetworkManager-wait-online.service
    systemd.services.NetworkManager-wait-online.enable = false;

    # Use iwd as NetworkManager backend
    networking.wireless.iwd.enable = true;
    networking.networkmanager.wifi.backend = "iwd";

    # Firewall
    networking.firewall = {
      enable = true;
      ports = [
        # Barrier / Input-Leap / Deskflow
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
      udisks2.enable = true;

      # Auto nice deamon
      ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };
    };

    # Hardware
    services.fwupd.enable = true;
    hardware.bluetooth.enable = true;
    hardware.sane.enable = true; # Scanners
    services.printing = {
      enable = true;
      drivers = with pkgs; [ splix ];
    };

    # Enable sound with pipewire.
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Fonts
    fonts.fontconfig.enable = true;
    fonts.packages = with pkgs; [
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

    # Home-Manager for desktop
    home-manager.users."rafalb8" = {
      imports = [ ./home.nix ];
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
