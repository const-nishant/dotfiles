#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Run with sudo: sudo bash $0" >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET_USER="${SUDO_USER:-const-nishant}"
TARGET_GROUP="sddm"
THEME_DIR="/usr/share/sddm/themes/kanji"
DYN_DIR="/var/lib/ii-sddm-kanji"
CONF_DIR="/etc/sddm.conf.d"
CONF_FILE="$CONF_DIR/10-theme.conf"
BACKUP_DIR="/etc/sddm.conf.d.before-kanji"
BACKUP_CONF="$BACKUP_DIR/10-theme.conf"
STAMP="$(date +%Y%m%d-%H%M%S)"

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "User not found: $TARGET_USER" >&2
  exit 1
fi
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
WALLPAPER_SRC="$TARGET_HOME/Pictures/Wallpapers/dual/main-eDP-1.jpg"
if ! getent group "$TARGET_GROUP" >/dev/null 2>&1; then
  TARGET_GROUP="$(id -gn "$TARGET_USER")"
fi

if [[ -d "$THEME_DIR" ]]; then
  mv "$THEME_DIR" "${THEME_DIR}.bak.${STAMP}"
  echo "Backed up old theme to ${THEME_DIR}.bak.${STAMP}"
fi

install -d -m755 "$THEME_DIR/backgrounds" "$THEME_DIR/screenshots"
install -m644 "$SCRIPT_DIR/Main.qml" "$THEME_DIR/Main.qml"
install -m644 "$SCRIPT_DIR/metadata.desktop" "$THEME_DIR/metadata.desktop"
if [[ -f "$SCRIPT_DIR/backgrounds/itachi.png" ]]; then
  install -m644 "$SCRIPT_DIR/backgrounds/itachi.png" "$THEME_DIR/backgrounds/itachi.png"
fi
if [[ -f "$SCRIPT_DIR/screenshots/preview.png" ]]; then
  install -m644 "$SCRIPT_DIR/screenshots/preview.png" "$THEME_DIR/screenshots/preview.png"
fi

chown -R root:root "$THEME_DIR"
chmod -R u=rwX,go=rX "$THEME_DIR"

install -d -m755 "$DYN_DIR"
chown "$TARGET_USER:$TARGET_GROUP" "$DYN_DIR"
chmod 755 "$DYN_DIR"
install -o "$TARGET_USER" -g "$TARGET_GROUP" -m644 "$SCRIPT_DIR/theme.conf" "$DYN_DIR/theme.conf"
if [[ -f "$SCRIPT_DIR/backgrounds/wall.jpg" ]]; then
  install -o "$TARGET_USER" -g "$TARGET_GROUP" -m644 "$SCRIPT_DIR/backgrounds/wall.jpg" "$DYN_DIR/wall.jpg"
elif [[ -f "$WALLPAPER_SRC" ]]; then
  install -o "$TARGET_USER" -g "$TARGET_GROUP" -m644 "$WALLPAPER_SRC" "$DYN_DIR/wall.jpg"
else
  echo "Warning: no wallpaper found; run $TARGET_HOME/.config/ii-sddm-kanji/sync.sh after install." >&2
fi

ln -sfn "$DYN_DIR/theme.conf" "$THEME_DIR/theme.conf"
ln -sfn "$DYN_DIR/wall.jpg" "$THEME_DIR/backgrounds/wall.jpg"
chown -h root:root "$THEME_DIR/theme.conf" "$THEME_DIR/backgrounds/wall.jpg"

install -d -m755 "$CONF_DIR" "$BACKUP_DIR"

# SDDM reads every regular file in /etc/sddm.conf.d, including backups.
# Keep the rollback copy outside that directory.
if [[ -f "$CONF_DIR/10-theme.conf.before-kanji" ]]; then
  mv -f "$CONF_DIR/10-theme.conf.before-kanji" "$BACKUP_CONF"
fi
if [[ ! -f "$BACKUP_CONF" ]]; then
  if [[ -f "$CONF_FILE" ]]; then
    cp -a "$CONF_FILE" "$BACKUP_CONF"
  else
    printf '[Theme]\nCurrent=sddm-astronaut-theme\n' > "$BACKUP_CONF"
  fi
  echo "Backed up SDDM theme selection to $BACKUP_CONF"
fi

printf '[Theme]\nCurrent=kanji\n' > "$CONF_FILE"

# /etc/sddm.conf takes precedence over conf.d, so update a stale Current there too.
if [[ -f /etc/sddm.conf ]] && grep -qE '^[[:space:]]*Current[[:space:]]*=' /etc/sddm.conf; then
  if [[ ! -f /etc/sddm.conf.before-kanji ]]; then
    cp -a /etc/sddm.conf /etc/sddm.conf.before-kanji
  fi
  sed -i -E 's|^[[:space:]]*Current[[:space:]]*=.*|Current=kanji|' /etc/sddm.conf
  echo "Updated /etc/sddm.conf (backup: /etc/sddm.conf.before-kanji)"
fi

echo
echo "Kanji dynamic SDDM theme installed."
echo "Dynamic files: $DYN_DIR"
echo "Theme entry:   $THEME_DIR"
echo
echo "Next, as your normal user:"
echo "  $TARGET_HOME/.config/ii-sddm-kanji/sync.sh"
echo "  systemctl --user daemon-reload"
echo "  systemctl --user enable --now kanji-sddm-sync.path kanji-sddm-sync.service"
echo
echo "Preview:"
echo "  sddm-greeter-qt6 --test-mode --theme $THEME_DIR"
echo "Apply: log out or reboot."
echo
echo "Rollback:"
echo "  sudo cp -a $BACKUP_CONF $CONF_FILE"
echo "  sudo rm -rf $THEME_DIR"
echo "  sudo rm -rf $DYN_DIR"
