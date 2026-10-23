#!/usr/bin/env bash
set -euo pipefail

parts=()

battery=""
for bat in /sys/class/power_supply/BAT*; do
    [[ -e "$bat" ]] || continue
    capacity="$(cat "$bat/capacity" 2>/dev/null || true)"
    status="$(cat "$bat/status" 2>/dev/null || true)"
    if [[ -n "$capacity" ]]; then
        if [[ "$status" == "Charging" ]]; then
            battery="Battery ${capacity}% (charging)"
        else
            battery="Battery ${capacity}%"
        fi
        break
    fi
done
if [[ -n "$battery" ]]; then
    parts+=("$battery")
fi

volume="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
if [[ "$volume" =~ Volume:\ ([0-9.]+) ]]; then
    percent="$(awk -v value="${BASH_REMATCH[1]}" 'BEGIN { printf "%d", value * 100 }')"
    if [[ "$volume" == *MUTED* ]]; then
        parts+=("Muted")
    else
        parts+=("Volume ${percent}%")
    fi
fi

ssid="$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '$1 == "yes" { print $2; exit }')"
if [[ -n "$ssid" ]]; then
    parts+=("Wi-Fi ${ssid}")
fi

line=""
for part in "${parts[@]}"; do
    line+="${line:+  ·  }${part}"
done
printf '%s\n' "$line"
