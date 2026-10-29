# Nishant's dotfiles

Arch Linux + Hyprland + [end-4/illogical-impulse](https://github.com/end-4/dots-hyprland) rice, managed with [chezmoi](https://www.chezmoi.io/).

## Stack

- Arch Linux, Hyprland (Lua config), end-4/illogical-impulse Quickshell shell
- kitty + fish + Starship
- Matugen / Material You dynamic colors
- Kanji SDDM login with dynamic wallpaper and palette
- Intel iGPU for Hyprland; RTX 3050 used through `prime-run`

## Managed files

- `~/.config/hypr/custom/` — user Lua config and scripts
- `~/.config/hypr/hyprlock.conf`, `~/.config/hypr/hyprlock/*.sh`
- `~/.config/hypr/hypridle.conf`
- `~/.config/hypr/monitors.lua`, `~/.config/hypr/workspaces.lua` — written by nwg-displays, keyed to my two displays by description
- `~/.config/matugen/` — config and templates (the generated outputs are not tracked)
- `~/.config/kitty/` (config and helper scripts), `~/.config/foot/`, `~/.config/fuzzel/fuzzel.ini`
- `~/.config/fish/config.fish`, `~/.config/fish/auto-Hypr.fish`, `~/.config/fish/conf.d/fish_frozen_key_bindings.fish`
- `~/.config/starship.toml`, `~/.config/cava/`, `~/.config/mpv/mpv.conf`, `~/.config/git/ignore`
- `~/.config/mimeapps.list`, `~/.config/wlogout/`, `~/.config/nwg-displays/config`, `~/.config/kde-material-you-colors/config.conf`, `~/.config/zshrc.d/` (without the installer-owned `dots-hyprland.zsh`)
- `~/.config/kdeglobals` is seeded once with `create_` and never overwritten, because most of it is colours that kde-material-you-colors rewrites with each wallpaper
- `~/.config/zed/settings.json`, `~/.config/easyeffects/db/` presets, `~/.config/Kvantum/kvantum.kvconfig`
- `~/.config/fontconfig/fonts.conf`, `~/.config/fontconfig/conf.d/50-windows-aliases.conf`
- `~/.config/gtk-3.0/settings.ini`
- `~/.config/illogical-impulse/monitor-wallpapers.json`
- `~/.config/ii-sddm-kanji/sync.sh`, `~/.config/ii-sddm-kanji/fix-sddm-backup.sh`
- `~/.config/systemd/user/kanji-sddm-sync.path`, `~/.config/systemd/user/kanji-sddm-sync.service`
- `packages/pacman.txt`, `packages/aur.txt` — explicitly installed packages, kept current by a pacman hook
- `system/` — files that live outside `$HOME`, applied by `system/install-system.sh`

## Not managed

- `~/.config/illogical-impulse/config.json` — contains personal work-safety keyword lists. The lock-clock change is available as a patch instead.
- Generated files that Matugen rewrites on every wallpaper change: the GTK 3/4 CSS, `fuzzel_theme.ini`, and the hypr colour files.
- Quickshell state, caches, browser/app data, backups, and credentials (`gh`, `opencode`, SSH and GPG keys are in `.chezmoiignore`).
- Root-owned SDDM theme files. Use the installer under `docs/sddm/`.

## Apply

1. Install the end-4/illogical-impulse setup first. These dotfiles are an overlay, not a standalone Hyprland install. The `hyprland.*` Lua modules and `quickshell/ii` come from it, and the Matugen colour files are generated the first time a wallpaper is set.
2. Install chezmoi and apply:

   ```bash
   sudo pacman -S --needed chezmoi
   chezmoi init --apply https://github.com/const-nishant/dotfiles.git
   ```

   Then restore the packages and the system-level files:

   ```bash
   sudo pacman -S --needed - < ~/.local/share/chezmoi/packages/pacman.txt
   yay -S --needed - < ~/.local/share/chezmoi/packages/aur.txt
   bash ~/.local/share/chezmoi/system/install-system.sh
   ```

   `install-system.sh` installs the reflector and journald configs, enables the `paccache` and `reflector` timers, and installs the pacman hook that regenerates the package lists. The hook only rewrites the lists; committing them is manual.

3. Set fish as the login shell:

   ```bash
   chsh -s /usr/bin/fish
   ```

4. Reapply the patches after upstream updates:

   ```bash
   cd ~
   patch -p1 < ~/.local/share/chezmoi/docs/patches/per-monitor-wallpaper.patch
   patch -p1 < ~/.local/share/chezmoi/docs/patches/hyprland-rules-no-blur.patch
   patch -p1 < ~/.local/share/chezmoi/docs/patches/ii-lock-clock.patch
   patch -p1 < ~/.local/share/chezmoi/docs/patches/ii-ec-shift-mode.patch
   ```

5. Install the Kanji SDDM theme:

   ```bash
   sudo bash ~/.local/share/chezmoi/docs/sddm/kanji-dynamic/install-kanji-dynamic.sh
   ~/.config/ii-sddm-kanji/sync.sh
   systemctl --user daemon-reload
   systemctl --user enable --now kanji-sddm-sync.path kanji-sddm-sync.service
   ```

   Once the theme is installed, later `chezmoi apply` runs enable these units automatically (`run_onchange_after_enable-kanji-units.sh.tmpl`). The script skips itself until `/var/lib/ii-sddm-kanji` exists.

   Then log out or reboot. Do not restart SDDM from inside Hyprland.

## Notes

- The primary lock screen is Quickshell/ii; hyprlock is a fallback when Quickshell is not running.
- hypridle is started by Hyprland and uses 10 min lock / 20 min display off / 30 min suspend.
- The Kanji theme reads dynamic files from `/var/lib/ii-sddm-kanji` through symlinks; the sync service updates them from the current Matugen palette and eDP-1 wallpaper.
- SDDM reads every regular file in `/etc/sddm.conf.d`, including backups. The installer keeps its rollback copy outside that directory.
