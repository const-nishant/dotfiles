# Kanji SDDM theme

This is the Kanji theme with a dynamic Matugen palette and eDP-1 wallpaper.

## Install

```bash
sudo bash docs/sddm/kanji-dynamic/install-kanji-dynamic.sh
~/.config/ii-sddm-kanji/sync.sh
systemctl --user daemon-reload
systemctl --user enable --now kanji-sddm-sync.path kanji-sddm-sync.service
```

Log out or reboot to apply. Do not restart SDDM from inside a Hyprland session.

## Dynamic files

- `/usr/share/sddm/themes/kanji/theme.conf` → `/var/lib/ii-sddm-kanji/theme.conf`
- `/usr/share/sddm/themes/kanji/backgrounds/wall.jpg` → `/var/lib/ii-sddm-kanji/wall.jpg`

`sync.sh` writes the palette from `~/.local/state/quickshell/user/generated/colors.json` and copies the eDP-1 wallpaper from `monitor-wallpapers.json`. The systemd path unit watches those files.

## Optional artwork

The public source intentionally omits images. The installer uses the current eDP-1 wallpaper if no `backgrounds/wall.jpg` is present. To add the optional Itachi art or a preview, place them at:

```text
backgrounds/itachi.png
screenshots/preview.png
backgrounds/wall.jpg
```

and rerun the installer.

## Rollback

The installer keeps the previous SDDM selection outside `/etc/sddm.conf.d`:

```bash
sudo cp -a /etc/sddm.conf.d.before-kanji/10-theme.conf /etc/sddm.conf.d/10-theme.conf
sudo rm -rf /usr/share/sddm/themes/kanji
sudo rm -rf /var/lib/ii-sddm-kanji
systemctl --user disable --now kanji-sddm-sync.path kanji-sddm-sync.service
```

SDDM reads every regular file in `/etc/sddm.conf.d`, not just `*.conf`. Keep backups out of that directory.
