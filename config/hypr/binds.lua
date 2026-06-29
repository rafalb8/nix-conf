-- Apps
local term = "ghostty"
local uwsm = "uwsm-app -- "
hl.bind("SUPER + T", hl.dsp.exec_cmd(uwsm .. term))
hl.bind("SUPER + B", hl.dsp.exec_cmd(uwsm .. "firefox"))
hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd(uwsm .. "walker"), { release = true })

-- Basic binds
hl.bind("SUPER + L", hl.dsp.exec_cmd(uwsm .. "hyprlock"))
hl.bind("Print", hl.dsp.exec_cmd(uwsm .. "prntscrn"))
hl.bind("ALT + SHIFT + S", hl.dsp.exec_cmd(uwsm .. "prntscrn 0"))
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd(uwsm .. term .. " -e btop"))
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(uwsm .. "powermenu"))
hl.bind("XF86Calculator", hl.dsp.exec_cmd(uwsm .. "gnome-calculator"))

-- Window binds
hl.bind("SUPER + Return", hl.dsp.window.fullscreen({ mode = 0 })) -- Fullscreen
hl.bind("SUPER + W", hl.dsp.window.close())
hl.bind("SUPER + F", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.center())
end)

-- PiP bind
hl.bind("SUPER + P", function()
    hl.dispatch(hl.dsp.window.float({ action = "on" }))
    hl.dispatch(hl.dsp.window.pin({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.resize({ exact = true, x = 640, y = 360 }))
    hl.dispatch(hl.dsp.window.move({ direction = "right" }))
    hl.dispatch(hl.dsp.window.move({ direction = "up" }))
end)

-- Move focus with mainMod + arrow keys
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))

-- Move window position within the layout
hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- Workspace binds
hl.bind("SUPER + Tab", hl.dsp.focus({ workspace = "previous" }))
for key = 0, 9 do
    hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = key }))
end

for key = 0, 9 do
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = key }))
end

-- Magic workspace
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Mouse
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume Control
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"),
    { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("SUPER + V", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

-- Media Control
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(uwsm .. "brightnessctl set 5%+"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(uwsm .. "brightnessctl set 5%-"), { repeating = true, locked = true })
