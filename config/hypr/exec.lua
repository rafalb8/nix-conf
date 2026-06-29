local uwsm_session = "uwsm-app -s s -t service -p 'Restart=on-failure' -- "
local uwsm_background = "uwsm-app -s b -t service -p 'Restart=on-failure' -- "

hl.on("hyprland.start", function()
    hl.exec_cmd(uwsm_session .. "waybar")
    hl.exec_cmd(uwsm_session .. "swaync")
    hl.exec_cmd(uwsm_session .. "elephant")
    hl.exec_cmd(uwsm_session .. "hypridle")
    hl.exec_cmd(uwsm_session .. "sway-audio-idle-inhibit")
    hl.exec_cmd(uwsm_session .. "walker --gapplication-service")

    hl.exec_cmd(uwsm_background .. "hyprpaper")
end)
