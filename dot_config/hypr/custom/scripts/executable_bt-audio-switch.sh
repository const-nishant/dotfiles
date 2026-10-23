#!/usr/bin/env bash
# Auto-switches default sink + EasyEffects preset when the Predator Xo1
# Bluetooth earbuds connect/disconnect.

BT_SINK="bluez_output.3E_12_EF_B1_69_58.1"
SPEAKER_SINK="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink"
BT_PRESET="GF63-Bluetooth"
SPEAKER_PRESET="GF63-Speakers"

switch_to() {
    local sink="$1" preset="$2"
    local current
    current="$(pactl get-default-sink)"
    if [[ "$current" != "$sink" ]]; then
        pactl set-default-sink "$sink"
        easyeffects -l "$preset"
    fi
}

pactl subscribe 2>/dev/null | while read -r line; do
    case "$line" in
        # Only react when a sink actually appears/disappears (BT connect/disconnect),
        # not on every volume/mute/suspend-resume change of an already-existing sink -
        # otherwise this fights any manual switch to a non-BT, non-speaker device (USB, HDMI, ...).
        *"'new' on sink"*|*"'remove' on sink"*)
            if pactl list sinks short | grep -q "$BT_SINK"; then
                switch_to "$BT_SINK" "$BT_PRESET"
            elif [[ "$(pactl get-default-sink)" == "$BT_SINK" ]]; then
                # BT sink just disappeared and was in use -> fall back to the speaker.
                # If some other sink (USB, HDMI, ...) was in use, leave it alone.
                switch_to "$SPEAKER_SINK" "$SPEAKER_PRESET"
            fi
            ;;
    esac
done
