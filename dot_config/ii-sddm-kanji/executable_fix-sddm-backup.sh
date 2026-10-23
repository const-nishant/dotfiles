#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Run with sudo: sudo bash $0" >&2
  exit 1
fi

CONF_DIR="/etc/sddm.conf.d"
CONF_FILE="$CONF_DIR/10-theme.conf"
BACKUP_DIR="/etc/sddm.conf.d.before-kanji"
BACKUP_OLD="$CONF_DIR/10-theme.conf.before-kanji"
BACKUP_NEW="$BACKUP_DIR/10-theme.conf"

install -d -m755 "$BACKUP_DIR"

# SDDM reads every regular file in /etc/sddm.conf.d, not just *.conf.
# The old backup therefore overrode the active file with astronaut.
if [[ -f "$BACKUP_OLD" ]]; then
  mv -f "$BACKUP_OLD" "$BACKUP_NEW"
  echo "Moved backup out of SDDM's config directory:"
  echo "  $BACKUP_OLD -> $BACKUP_NEW"
fi

printf '[Theme]\nCurrent=kanji\n' > "$CONF_FILE"
chmod 644 "$CONF_FILE"
chown root:root "$CONF_FILE"

# /etc/sddm.conf is read last and overrides conf.d.
if [[ -f /etc/sddm.conf ]] && grep -qE '^[[:space:]]*Current[[:space:]]*=' /etc/sddm.conf; then
  if [[ ! -f /etc/sddm.conf.before-kanji ]]; then
    cp -a /etc/sddm.conf /etc/sddm.conf.before-kanji
  fi
  sed -i -E 's|^[[:space:]]*Current[[:space:]]*=.*|Current=kanji|' /etc/sddm.conf
  echo "Updated /etc/sddm.conf to Current=kanji"
fi

echo
echo "Active SDDM config files:"
ls -la "$CONF_DIR"
echo
echo "Current values SDDM will read:"
grep -RIn --exclude='*.before-kanji' '^[[:space:]]*Current[[:space:]]*=' "$CONF_DIR" || true
echo
echo "Log out or reboot to apply. Do not restart SDDM from inside Hyprland."
