local uwsm_session = "uwsm-app -s s -t service -p 'Restart=on-failure' -- "
local uwsm_background = "uwsm-app -s b -t service -p 'Restart=on-failure' -- "

hl.on("hyprland.start", function()
    hl.exec_cmd(uwsm_session .. "noctalia")
end)
