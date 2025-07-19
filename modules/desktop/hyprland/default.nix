{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  imports = [
    ./hypr
    ./rofi.nix
    ./waybar.nix
  ];

  config = lib.mkIf cfg.environment.hyprland {
    services = {
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
      gvfs.enable = true;
    };

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    # Default running apps in wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    environment.systemPackages = with pkgs; [
      # Gnome apps
      ghex
      nautilus
      overskride # Bluetooth client
      mission-center
      gnome-calculator

      wlogout
      hyprshot
      hypridle
      hyprlock
      # waypaper
      # hyprpaper
      # hyprsunset
      hyprpolkitagent

      # utils
      playerctl
      brightnessctl
      networkmanagerapplet

      # maybe
      qt6ct
      nwg-look
      nwg-dock-hyprland
    ];

    # Fix nautilus shortcut
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "alacritty";
    };

    home-manager.users.${config.user.name} = { config, lib, ... }: {
      wayland.windowManager.hyprland.enable = true;
      wayland.windowManager.hyprland.settings = {
        exec-once = [
          "systemctl --user start waybar"
          "systemctl --user start hypridle"
          "systemctl --user start hyprpaper"
          "systemctl --user start hyprpolkitagent"
        ];

        env = [
          "HYPRSHOT_DIR,${config.home.homeDirectory}/Pictures/Screenshots"
        ];

        monitor = [
          # output, resolution, position, scale, args ...
          "DP-1, highrr, 0x0, 1, cm, auto, vrr, 3"
          ", preferred, auto, auto"
        ];
      };
    };
  };
}
