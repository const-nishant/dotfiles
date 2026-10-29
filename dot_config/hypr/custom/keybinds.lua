hl.bind("CTRL+SUPER+ALT+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), {description = "Edit user keybinds"} )

-- Windows-style Alt-Tab: hold Alt, tap Tab to cycle through windows (MRU order,
-- visual overlay), release Alt to switch to the selected window.
hl.bind("ALT + Tab", hl.dsp.exec_cmd("hyprswitch gui --mod-key ALT --key tab --close mod-key-release --sort-recent"),
    { description = "Window: Alt-Tab switcher" })
hl.bind("ALT", hl.dsp.exec_cmd("hyprswitch close"), { release = true, description = "Window: Alt-Tab commit selection" })
