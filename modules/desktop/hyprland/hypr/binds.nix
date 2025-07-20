{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    bind = [
      # Programs
      "$mod, T, exec, alacritty"
      "CTRL SHIFT, Escape, exec, missioncenter"

      # Basic
      "$mod, W, killactive"
      "$mod, F, togglefloating"
      "$mod SHIFT, F, workspaceopt, allfloat"
      "$mod ALT, Enter, fullscreen, 0"
      "ALT, SPACE, exec, rofi -show drun"
      "CTRL ALT, DELETE, exec, wlogout"

      # Screenshots
      ", Print, exec, hyprshot -m output"
      "$mod, Print, exec, hyprshot -m window"
      "$mod SHIFT, Print, exec, hyprshot -m region"

      # Switch to workspace
      "CTRL ALT, Right, workspace, m+1"
      "CTRL ALT, Left, workspace, m-1"

      # Move window to next workspace
      "$mod SHIFT, Right, movetoworkspace, e+1"
      "$mod SHIFT, Left, movetoworkspace, e-1"

      # Special Keys
      ", XF86Lock, exec, hyprlock"
      ", XF86Calculator, exec, gnome-calculator"
      ", XF86MonBrightnessUp, exec, brightnessctl -q s +10%"
      ", XF86MonBrightnessDown, exec, brightnessctl -q s 10%-"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPause, exec, playerctl pause"
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPrev, exec, playerctl previous"
      ", XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
      ", XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle"
    ];

    bindle = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
    ];

    binde = [
      "$mod, Tab, cyclenext"
      "$mod, Tab, bringactivetotop"
    ];

    bindm = [
      # Move/resize windows with mainMod + LMB/RMB and dragging
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];
  };
}
