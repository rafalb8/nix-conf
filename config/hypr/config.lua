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

        gaps_in = 5,
        gaps_out = 5,
        border_size = 1,
        allow_tearing = true,
        col = {
            active_border = { colors = { "rgba(77A8D9ff)", "rgba(1F2430ff)" }, angle = 45 },
            inactive_border = "rgba(1F2430ff)",
        },
    },

    decoration = {
        rounding = 5,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "0xee1a1a1a",
        },

        blur = {
            enabled = true,
            size = 3,
            passes = 2,
            vibrancy = 0.1696,
        },
    },
})
