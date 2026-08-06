local term = "ghostty"
local uwsm = "uwsm-app -- "
local ipc = "noctalia msg "

-- Core
hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind("SUPER + COMMA", hl.dsp.exec_cmd(ipc .. "settings-toggle"))

-- Apps
hl.bind("SUPER + T", hl.dsp.exec_cmd(uwsm .. term))
hl.bind("SUPER + B", hl.dsp.exec_cmd(uwsm .. "firefox"))

-- Basic binds
hl.bind("SUPER + L", hl.dsp.exec_cmd(ipc .. "session lock"))
hl.bind("Print", hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen"))
hl.bind("ALT + SHIFT + S", hl.dsp.exec_cmd(ipc .. "screenshot-region"))
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd(uwsm .. term .. " -e btop"))
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(ipc .. "panel-open session"))
hl.bind("XF86Calculator", hl.dsp.exec_cmd(uwsm .. "gnome-calculator"))

-- Window binds
hl.bind("ALT + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher"))
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
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume-up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume-down"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. "volume-mute"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(ipc .. "mic-mute"), { locked = true })
hl.bind("SUPER + V", hl.dsp.exec_cmd(ipc .. "mic-mute"), { locked = true })

-- Media Control
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(ipc .. "media toggle"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(ipc .. "media next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(ipc .. "media previous"), { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. "brightness-up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness-down"))
