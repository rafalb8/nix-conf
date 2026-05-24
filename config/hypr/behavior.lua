-- Look & Feel --
hl.config({
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },

    input = {
        sensitivity = 0.5,
        accel_profile = "flat",
        touchpad = {
            natural_scroll = true,
        },

        -- Keyboard
        kb_layout = "pl",
        numlock_by_default = true,
        -- kb_options = "grp:win_space_toggle",
    },

    general = {
        layout = "dwindle",

        gaps_in = 4,
        gaps_out = 4,
        border_size = 1,
        allow_tearing = true,
        col = {
            active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
    },

    dwindle = {
        smart_split = true,
    },

    decoration = {
        rounding = 5,
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
        },
        dim_special = 0.5,
    },
})

-- Window Rules --

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
    name = "game-content",
    match = {
        class = "^(gamescope|steam_app_.*|cs2)$",
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
