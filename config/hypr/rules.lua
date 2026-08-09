hl.workspace_rule({ workspace = "1", monitor = "", persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "", persistent = true })
hl.workspace_rule({ workspace = "4", monitor = "", persistent = true })
hl.workspace_rule({ workspace = "5", monitor = "", persistent = true })

-- Noctalia Settings
hl.window_rule({
    match = { class = "dev.noctalia.Noctalia" },
    float = true,
    size = { 1080, 920 },
})

hl.layer_rule({
    name = "noctalia",
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
    },
    no_anim = true,
    ignore_alpha = 0.5,
    blur = true,
    blur_popups = true,
})

-- Gaming
hl.window_rule({
    name = "steam-dialog",
    match = {
        class = "^(steam)$",
        title = "negative:^(Steam)$",
    },
    float = true,
})

hl.window_rule({
    name = "steam-big-picture",
    match = {
        class = "^(steam)$",
        title = "^(Steam Big Picture Mode)$",
    },
    content = "game",
})

hl.window_rule({
    name = "gamescope",
    match = {
        class = "^.*gamescope.*$",
    },
    content = "game",
})

hl.window_rule({
    name = "game-content",
    match = {
        class = "^(steam_app_.*|cs2|bg3)$",
    },
    content = "game",
})

hl.window_rule({
    name = "games",
    match = {
        content = "game",
    },
    immediate = true,
    no_blur = true,
    no_shadow = true,
    rounding = 0,
    workspace = 3,
    center = true,
})

-- Special
hl.window_rule({
    name = "float-magic",
    match = {
        workspace = "special:magic",
    },
    float = true,
    size = "monitor_w/3 monitor_h/2",
})

hl.window_rule({
    name = "discord-magic",
    match = {
        class = "^(discord)$",
    },
    workspace = "special:magic silent",
    float = true,
    size = "monitor_w*45/100 monitor_h-32",
    move = "monitor_w*55/100 32",
})

-- Media
hl.window_rule({
    name = "jellyfin",
    match = {
        class = "^(org.jellyfin.JellyfinDesktop)$",
    },
    content = "video",
})

hl.window_rule({
    name = "mpv",
    match = {
        class = "^(mpv)$",
    },
    content = "video",
    float = true,
})

hl.window_rule({
    name = "firefox-pip",
    match = {
        title = "^(Picture-in-Picture)$",
        class = "^(firefox)$",
    },
    content = "video",
    pin = true,
    float = true,
    size = "640 360",
    move = "monitor_w-window_w-2 32+2",
})

-- Popups
hl.window_rule({
    name = "waybar-tui-popups",
    match = {
        class = "waybar.popup",
    },
    float = true,
    size = "1280 720",
    center = true,
})

hl.window_rule({
    name = "calculator",
    match = {
        class = "^(org.gnome.Calculator)$",
    },
    size = "370 720",
    float = true,
    center = true,
})

hl.window_rule({
    name = "file-picker",
    match = {
        class = "xdg-desktop-portal-gtk",
    },
    float = true,
    center = true,
})
