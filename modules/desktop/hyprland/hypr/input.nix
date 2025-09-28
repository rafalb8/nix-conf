{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = "pl";
      numlock_by_default = true;

      sensitivity = 0;
      follow_mouse = 1;
      mouse_refocus = false;
      accel_profile = "flat";

      touchpad = {
        natural_scroll = false;
        scroll_factor = 1.0;
      };
    };
  };
}
