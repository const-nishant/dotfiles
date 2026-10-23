hl.on("hyprland.start", function ()
    hl.exec_cmd("hyprswitch init --show-title")
    hl.exec_cmd("$HOME/.config/hypr/custom/scripts/bt-audio-switch.sh")
end)
