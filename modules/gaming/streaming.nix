{ config, pkgs, lib, paths, ... }:
let
  cfg = config.modules.gaming;
  sunscreen = pkgs.custom.sunscreen;

  hypr-conf = pkgs.writeText "hyprland.lua" ''
    -- Monitors
    hl.monitor({
        output = "HEADLESS-2",
        mode = "3840x2160@60",
        position = "auto",
        scale = 1,
    })

    hl.monitor({
        output = "",
        mode = "preferred",
        position = "auto",
        scale = "auto",
    })

    hl.on("hyprland.start", function()
        -- Create Headless monitor and disable real display
        hl.exec_cmd("hyprctl output create headless HEADLESS-2")
        hl.exec_cmd("hyprctl keyword monitor DP-1, disabled")

        -- Start programs
        hl.exec_cmd("systemctl restart --user sunshine.service")
    end)

    -- Hyprsun binds
    hl.bind("CTRL + ALT + Delete", hl.dsp.exit())
    hl.bind("SUPER + P", hl.dsp.exec_cmd("sunscreen steam"))

    -- Binds
    ${builtins.readFile "${paths.hypr}/binds.lua"}

    -- Behaviour
    ${builtins.readFile "${paths.hypr}/behavior.lua"}

    -- Override games window rule
    hl.window_rule({
        name = "games",
        match = {
            content = "game",
        },
        immediate = "on",
        no_blur = "on",
        no_shadow = "on",
        rounding = 0,
    })
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
