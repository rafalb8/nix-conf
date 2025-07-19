{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.environment.hyprland {
    home-manager.users.${config.user.name}.programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      modes = [ "drun" "run" "window" ];
      extraConfig = {
        show-icons = true;
        display-drun = " ";
        display-run = " ";
        display-window = "  ";
        drun-display-format = "{name}";
        hover-select = false;
        scroll-method = 1;
        me-select-entry = "";
        me-accept-entry = "MousePrimary";
        window-format = "{w} · {c} · {t}";
      };
    };
  };
}
