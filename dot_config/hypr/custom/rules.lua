hl.layer_rule({ match = { namespace = "hyprswitch" }, no_anim = true })

-- Keep blur off for media/heavy windows
hl.window_rule({ match = { class = "^(discord|Spotify|mpv|vlc|gamescope)$" }, no_blur = true })

-- Slight transparency for editor windows
hl.window_rule({ match = { class = "^(code|Code|zed|Zed|dev\\.zed\\.Zed)$" }, opacity = "0.96 0.92" })
