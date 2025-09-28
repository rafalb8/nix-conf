{ pkgs, ... }:
let
  keybindings = pkgs.writeShellScriptBin "show" ''
    USER_HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
    grep -h '^[[:space:]]*bind' "$USER_HYPRLAND_CONF" |
      awk -F, '
    {
        # Strip trailing comments
        sub(/#.*/, "");
    
        # Handle both "bind =" and "bind=" formats
        # Remove the "bind[el]?[m]?=" part and surrounding whitespace
        sub(/^[[:space:]]*bind[elm]*[[:space:]]*=[[:space:]]*/, "", $1);
    
        # Combine the modifier and key (first two fields)
        key_combo = $1 " + " $2;
    
        # Clean up: strip leading/trailing spaces and normalize
        gsub(/^[ \t]+|[ \t]+$/, "", key_combo);
        gsub(/[ \t]+/, " ", key_combo);
    
        # Reconstruct the command from the remaining fields
        action = "";
        for (i = 3; i <= NF; i++) {
            action = action $i (i < NF ? "," : "");
        }
    
        # Clean up action: remove "exec, " prefix and trim
        sub(/^[[:space:]]*exec[[:space:]]*,?[[:space:]]*/, "", action);
        gsub(/^[ \t]+|[ \t]+$/, "", action);
    
        # Only print if we have both key combo and action
        if (key_combo != "" && action != "") {
            printf "%-35s → %s\n", key_combo, action;
        }
    }' |
    flock --nonblock /tmp/.wofi.lock -c "wofi -dmenu -i --width 50% --height 40% -p 'Hyprland Keybindings' -O alphabetical"
  '';
in
{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    bind = [
      # Programs
      "$mod, T, exec, alacritty"
      "$mod, F, exec, nautilus"
      "$mod, B, exec, firefox"
      "CTRL SHIFT, Escape, exec, missioncenter"

      # Basic
      "$mod, W, killactive"
      "$mod, K, exec, ${keybindings}/bin/show"
      "$mod, space, exec, wofi --show drun --sort-order=alphabetical"

      # End active session
      "$mod, L, exec, hyprlock"
      "CTRL ALT, DELETE, exec, wlogout"

      # Control tiling
      "$mod, J, togglesplit, # dwindle"
      "$mod, P, pseudo, # dwindle"
      "$mod, V, togglefloating,"
      "$mod SHIFT, Plus, fullscreen,"

      # Move focus with $mod + arrow keys
      "$mod, left, movefocus, l"
      "$mod, right, movefocus, r"
      "$mod, up, movefocus, u"
      "$mod, down, movefocus, d"

      # Switch workspaces with $mod + [0-9]
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
      "$mod, 0, workspace, 10"

      "$mod, comma, workspace, -1"
      "$mod, period, workspace, +1"

      # Move active window to a workspace with $mod + SHIFT + [0-9]
      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      "$mod SHIFT, 6, movetoworkspace, 6"
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"
      "$mod SHIFT, 0, movetoworkspace, 10"

      # Swap active window with the one next to it with $mod + SHIFT + arrow keys
      "$mod SHIFT, left, swapwindow, l"
      "$mod SHIFT, right, swapwindow, r"
      "$mod SHIFT, up, swapwindow, u"
      "$mod SHIFT, down, swapwindow, d"

      # Resize active window
      "$mod, minus, resizeactive, -100 0"
      "$mod, equal, resizeactive, 100 0"
      "$mod SHIFT, minus, resizeactive, 0 -100"
      "$mod SHIFT, equal, resizeactive, 0 100"

      # Scroll through existing workspaces with $mod + scroll
      "$mod, mouse_down, workspace, e+1"
      "$mod, mouse_up, workspace, e-1"

      # Super workspace floating layer
      "$mod, S, togglespecialworkspace, magic"
      "$mod SHIFT, S, movetoworkspace, special:magic"

      # Screenshots
      ", PRINT, exec, hyprshot -m region"
      "SHIFT, PRINT, exec, hyprshot -m window"
      "CTRL, PRINT, exec, hyprshot -m output"

      # Special Keys
      ", XF86Lock, exec, hyprlock"
      ", XF86Calculator, exec, gnome-calculator"
    ];

    # repeat,locked - Repeats and works in locksceen
    bindel = [
      # Multimedia keys for volume and brightness
      ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
      ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
    ];

    # repeat - Will repeat when held
    binde = [
      "$mod, Tab, cyclenext"
      "$mod, Tab, bringactivetotop"
    ];

    # locked - Will work when lockscreen is active
    bindl = [
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
    ];

    # mouse- Mouse binds
    bindm = [
      # Move/resize windows with mainMod + LMB/RMB and dragging
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];
  };
}
