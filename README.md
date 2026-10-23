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
- `~/.config/kitty/kitty.conf`
- `~/.config/fish/config.fish`, `~/.config/fish/conf.d/conda.fish`
- `~/.config/fontconfig/fonts.conf`, `~/.config/fontconfig/conf.d/50-windows-aliases.conf`
- `~/.config/gtk-3.0/settings.ini`
- `~/.config/illogical-impulse/monitor-wallpapers.json`
- `~/.config/ii-sddm-kanji/sync.sh`, `~/.config/ii-sddm-kanji/fix-sddm-backup.sh`
- `~/.config/systemd/user/kanji-sddm-sync.path`, `~/.config/systemd/user/kanji-sddm-sync.service`

## Not managed

- `~/.config/illogical-impulse/config.json` — contains personal work-safety keyword lists. The lock-clock change is available as a patch instead.
- Generated Matugen colors, Quickshell state, caches, browser/app data, backups, and credentials.
- Root-owned SDDM theme files and `/etc` configuration. Use the installer under `docs/sddm/`.

## Apply

1. Install the end-4/illogical-impulse setup first. These dotfiles are an overlay, not a standalone Hyprland install.
2. Install chezmoi and apply:

   ```bash
   sudo pacman -S --needed chezmoi
   chezmoi init --apply https://github.com/const-nishant/dotfiles.git
   ```

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
   ```

5. Install the Kanji SDDM theme:

   ```bash
   sudo bash ~/.local/share/chezmoi/docs/sddm/kanji-dynamic/install-kanji-dynamic.sh
   ~/.config/ii-sddm-kanji/sync.sh
   systemctl --user daemon-reload
   systemctl --user enable --now kanji-sddm-sync.path kanji-sddm-sync.service
   ```

   Then log out or reboot. Do not restart SDDM from inside Hyprland.

## Notes

- The primary lock screen is Quickshell/ii; hyprlock is a fallback when Quickshell is not running.
- hypridle is started by Hyprland and uses 10 min lock / 20 min display off / 30 min suspend.
- The Kanji theme reads dynamic files from `/var/lib/ii-sddm-kanji` through symlinks; the sync service updates them from the current Matugen palette and eDP-1 wallpaper.
- SDDM reads every regular file in `/etc/sddm.conf.d`, including backups. The installer keeps its rollback copy outside that directory.
