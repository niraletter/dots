#!/bin/bash

AC_PATH="/sys/class/power_supply/ADP1/online"

if [ ! -f "$AC_PATH" ]; then
    echo "Error: ADP1 not found!"
    exit 1
fi

old_state=$(cat "$AC_PATH")

while true; do
    new_state=$(cat "$AC_PATH")

    if [ "$new_state" != "$old_state" ]; then
        if [ "$new_state" -eq 1 ]; then
            notify-send "󱐋 Power Connected!" "Charger plugged in 󰂅"
        else
            notify-send "󱐋 Power Disconnected!" "Running on battery 󰁹"
        fi
        old_state="$new_state"
    fi

    sleep 0.1    # ← Changed from 5 to 1
done
