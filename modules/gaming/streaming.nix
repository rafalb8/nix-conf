{ config, pkgs, lib, paths, ... }:
let
  cfg = config.modules.gaming;
  sunscreen = pkgs.custom.sunscreen;

  hypr-conf = pkgs.writeText "hyprland.conf" ''
    monitor = HEADLESS-2, 3840x2160@60, auto, 1
    monitor = , preferred, auto, auto

    # Create Headless monitor and disable real display
    exec-once = hyprctl output create headless HEADLESS-2
    exec-once = hyprctl keyword monitor DP-1, disabled

    # Start programs
    exec-once = systemctl restart --user sunshine.service

    # Hyprsun binds
    bind = CTRL ALT, Delete, exit
    bind = SUPER, P, exec, sunscreen steam

    ${builtins.readFile "${paths.hypr}/binds.conf"}
    ${builtins.readFile "${paths.hypr}/behavior.conf"}
  '';
in
{
  config = lib.mkIf (cfg.enable && cfg.streaming.enable) {
    services.sunshine = {
      enable = true;
      autoStart = false;
      capSysAdmin = true;
      openFirewall = true;
    };

    services.sunshine = {
      # https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2configuration.html
      settings = {
        # mouse = "disabled";
        system_tray = "disabled";
        back_button_timeout = 1000;
      };

      applications.env = { PATH = "$(PATH):/run/current-system/sw/bin"; };
      applications.apps =
        let
          default = {
            exclude-global-prep-cmd = "";
            prep-cmd = [{
              do = ''${sunscreen}/bin/sunscreen mode'';
              undo = "${sunscreen}/bin/sunscreen reset";
            }];
            auto-detach = "true";
            exit-timeout = "5";
            wait-all = "true";
          };
        in
        [
          (default // {
            name = "Steam";
            image-path = "steam.png";
            detached = [ "${sunscreen}/bin/sunscreen steam" ];
          })
          (default // {
            name = "Desktop";
            image-path = "desktop.png";
            detached = [ "ghostty" ];
          })
        ];
    };

    # Fix for DS4/DualSense gamepads
    boot.kernelModules = [ "uhid" ];
    services.udev.extraRules = ''
      # sudo setfacl -m g:input:rw /dev/uhid
      SUBSYSTEM=="misc", KERNEL=="uhid", MODE="0660", GROUP="input", TAG+="uaccess"
      # Disable DS4/DualSense touchpad
      ATTRS{name}=="*Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      ATTRS{name}=="Sunshine PS5 (virtual) pad Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    '';

    # Add custom hyprland session
    environment.systemPackages = [ pkgs.hyprland sunscreen ];
    services.displayManager.sessionPackages =
      let
        launcher = pkgs.writeShellScript "launcher" ''
          export SUNSHINE=true
          systemctl --user import-environment SUNSHINE
          exec ${pkgs.hyprland}/bin/start-hyprland -- --config ${hypr-conf}
        '';
      in
      [
        (
          (pkgs.writeTextDir "share/wayland-sessions/hyprsun.desktop" ''
            [Desktop Entry]
            Version=1.0
            Name=Hyprsun
            Exec=${launcher}
            Type=Application
          '').overrideAttrs (_: { passthru.providedSessions = [ "hyprsun" ]; })
        )
      ];
  };
}
