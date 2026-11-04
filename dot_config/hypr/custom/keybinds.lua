hl.bind("CTRL+SUPER+ALT+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), {description = "Edit user keybinds"} )

-- Windows-style Alt-Tab: hold Alt, tap Tab to cycle through windows (MRU order,
-- visual overlay), release Alt to switch to the selected window.
hl.bind("ALT + Tab", hl.dsp.exec_cmd("hyprswitch gui --mod-key ALT --key tab --close mod-key-release --sort-recent"),
    { description = "Window: Alt-Tab switcher" })
hl.bind("ALT", hl.dsp.exec_cmd("hyprswitch close"), { release = true, description = "Window: Alt-Tab commit selection" })

-- Left sidebar (AI chat / translator / anime) is unused and all its tabs are disabled
-- in config.json, so free its toggle keys instead of opening an empty panel.
hl.unbind("SUPER + A")
hl.unbind("SUPER + ALT + A")
hl.unbind("SUPER + B")
hl.unbind("SUPER + O")
