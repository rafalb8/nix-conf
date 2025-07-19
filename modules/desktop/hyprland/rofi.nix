{ config, pkgs, ... }:
{
  home-manager.users.${config.user.name} = { config, lib, ... }: {
    # programs.pywal.enable = true;

    programs.rofi = {
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
