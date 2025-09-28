{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      # "systemctl --user start waybar"
      # "systemctl --user start hypridle"
      # "systemctl --user start hyprpaper"
      "hyprsunset"
      "systemctl --user start hyprpolkitagent"
    ];

    exec = [
      "pkill -SIGUSR2 waybar || waybar"
    ];
  };
}
