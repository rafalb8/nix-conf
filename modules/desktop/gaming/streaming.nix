{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;

  hypr-conf = let cfg = ../../../config/hypr; in pkgs.writeText "hyprland.conf" ''
    monitor = HEADLESS-2, 3840x2160@60, auto, 1
    monitor = , preferred, auto, auto

    # Create Headless monitor and disable real display
    exec-once = hyprctl output create headless HEADLESS-2
    exec-once = hyprctl keyword monitor DP-1, disabled

    # Start programs
    exec-once = systemctl restart --user sunshine.service

    # Hyprsun binds
    bind = CTRL ALT, Delete, exit
    bind = SUPER, T, exec, ghostty
    bind = SUPER, B, exec, firefox
    bind = SUPER, P, exec, sunscreen steam

    ${builtins.readFile "${cfg}/binds.conf"}
    ${builtins.readFile "${cfg}/behavior.conf"}
  '';

  sunscreen = pkgs.writeShellScriptBin "sunscreen" ''
    # Restart current script without CAP_SYS_ADMIN
    if getpcaps $$ | grep -q "cap_sys_admin"; then
      exec setpriv --inh-caps -sys_admin "$0" "$@"
    fi

    set -ex

    export MANGOHUD_CONFIG=preset=1

    WIDTH=''${SUNSHINE_CLIENT_WIDTH:-$(hyprctl monitors -j | jq ".[0].width")}
    HEIGHT=''${SUNSHINE_CLIENT_HEIGHT:-$(hyprctl monitors -j | jq ".[0].height")}
    FPS=''${SUNSHINE_CLIENT_FPS:-$(hyprctl monitors -j | jq ".[0].refreshRate | tonumber")}
    PROFILE="''${WIDTH}x''${HEIGHT}@''${FPS}"

    GAMESCOPE_CMD="exec gamescope -W ''${WIDTH} -H ''${HEIGHT} -r ''${FPS} \
            --immediate-flips --force-grab-cursor --mangoapp -f"

    case $1 in
      "reset") pkill -TERM gamescope ;;
      "mode") hyprctl keyword monitor HEADLESS-2, ''${PROFILE}, auto, 1 ;;
      "steam")
        pkill -TERM steam && pidwait steam && sleep 3
        $GAMESCOPE_CMD -e -- steam -gamepadui -steamos3 ;;
      *) $GAMESCOPE_CMD -- "$@"
    esac
  '';
in
{
  config = lib.mkIf (cfg.gaming.enable && cfg.gaming.streaming) {
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
          # (default // {
          #   name = "RPCS3";
          #   image-path = "${pkgs.rpcs3}/share/icons/hicolor/48x48/apps/rpcs3.png";
          #   detached = [ "${sunscreen}/bin/sunscreen rpcs3" ];
          # })
        ];
    };

    # Fix for DS4/DS5 gamepads
    boot.kernelModules = [ "uhid" ];
    services.udev.extraRules = ''
      # sudo setfacl -m g:input:rw /dev/uhid
      SUBSYSTEM=="misc", KERNEL=="uhid", MODE="0660", GROUP="input", TAG+="uaccess"
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
            Name=Sunshine on Hyprland
            Exec=${launcher}
            Type=Application
          '').overrideAttrs (_: { passthru.providedSessions = [ "hyprsun" ]; })
        )
      ];
  };
}
