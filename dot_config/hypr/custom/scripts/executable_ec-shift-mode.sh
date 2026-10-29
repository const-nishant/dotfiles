#!/usr/bin/env bash
# Cycles the MSI EC shift mode (eco -> comfort -> turbo) and shows a notification.
# The msi-ec sysfs files are group-writable by wheel, so no root is needed.
# Usage: ec-shift-mode.sh [cycle|show]

EC=/sys/devices/platform/msi-ec
ORDER=(eco comfort turbo)

current="$(cat "$EC/shift_mode" 2>/dev/null)"
if [[ -z "$current" ]]; then
    notify-send -u critical "Performance mode" "msi-ec not available"
    exit 1
fi

if [[ "$1" != "show" ]]; then
    next="${ORDER[0]}"
    for i in "${!ORDER[@]}"; do
        if [[ "${ORDER[$i]}" == "$current" ]]; then
            next="${ORDER[$(( (i + 1) % ${#ORDER[@]} ))]}"
            break
        fi
    done
    if ! echo "$next" > "$EC/shift_mode" 2>/dev/null; then
        notify-send -u critical "Performance mode" "Could not set $next (permission denied)"
        exit 1
    fi
    current="$(cat "$EC/shift_mode")"
fi

notify-send -h string:x-dunst-stack-tag:ec-shift-mode -t 1500 "Performance mode" "${current^}"
