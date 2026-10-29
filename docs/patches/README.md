# Patches

Apply from `$HOME` with `patch -p1`:

```bash
cd ~
patch -p1 < ~/.local/share/chezmoi/docs/patches/per-monitor-wallpaper.patch
patch -p1 < ~/.local/share/chezmoi/docs/patches/hyprland-rules-no-blur.patch
patch -p1 < ~/.local/share/chezmoi/docs/patches/ii-lock-clock.patch
patch -p1 < ~/.local/share/chezmoi/docs/patches/ii-ec-shift-mode.patch
```

- `per-monitor-wallpaper.patch` adds per-monitor wallpaper support to the end-4/illogical-impulse `Background.qml`. Reapply it after updating the upstream shell.
- `hyprland-rules-no-blur.patch` comments the global `no_blur` rule so targeted blur exceptions work.
- `ii-lock-clock.patch` enables the lock-only digital clock in `~/.config/illogical-impulse/config.json`. It is separate because the full config contains personal work-safety keyword lists and is not published.
- `ii-ec-shift-mode.patch` shows the MSI EC performance mode (eco/comfort/turbo) in the top-bar battery popup and on the sidebar Power Profile toggle, flagging it when it differs from the mode the power profile should give. `MsiEc.qml` re-reads the EC every 5 seconds so hotkey changes show up.

Upstream changes may make a patch fail. Inspect the rejected hunks before forcing anything.
