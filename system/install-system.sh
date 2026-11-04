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

# --- Network hardening (ufw, LLMNR off, Wi-Fi MAC randomization, key-only sshd) ---
sudo pacman -S --needed ufw
sudo install -Dm644 "$here/etc/NetworkManager/conf.d/10-privacy.conf" /etc/NetworkManager/conf.d/10-privacy.conf
sudo install -Dm644 "$here/etc/systemd/resolved.conf.d/10-no-llmnr.conf" /etc/systemd/resolved.conf.d/10-no-llmnr.conf
sudo install -Dm644 "$here/etc/ssh/sshd_config.d/10-hardening.conf" /etc/ssh/sshd_config.d/10-hardening.conf
sudo ssh-keygen -A >/dev/null   # host keys must exist for `sshd -t`
sudo sshd -t
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw --force enable
sudo systemctl enable --now ufw
sudo systemctl disable --now sshd 2>/dev/null || true   # lan-on starts it on demand
sudo systemctl restart systemd-resolved
sudo nmcli general reload conf
