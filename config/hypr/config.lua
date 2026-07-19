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
