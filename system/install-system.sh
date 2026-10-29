#!/usr/bin/env bash
# Installs system-level files that chezmoi can't manage (outside $HOME).
# Idempotent: safe to re-run. Run from the repo root: bash system/install-system.sh
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"

sudo pacman -S --needed pacman-contrib reflector
sudo install -Dm644 "$here/etc/xdg/reflector/reflector.conf" /etc/xdg/reflector/reflector.conf
sudo install -Dm644 "$here/etc/systemd/journald.conf.d/size.conf" /etc/systemd/journald.conf.d/size.conf
sudo install -Dm644 "$here/etc/pacman.d/hooks/99-package-lists.hook" /etc/pacman.d/hooks/99-package-lists.hook
sudo install -Dm755 "$here/usr/local/bin/update-package-lists" /usr/local/bin/update-package-lists
sudo systemctl enable --now paccache.timer reflector.timer
sudo systemctl restart systemd-journald
