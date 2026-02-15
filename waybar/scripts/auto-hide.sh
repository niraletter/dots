#!/bin/bash

WAYBAR_HEIGHT=40  # Change if needed
HIDE_DELAY=2

waybar &

while true; do
    Y=$(hyprctl cursorpos | cut -d',' -f2)

    if [ "$Y" -lt "$WAYBAR_HEIGHT" ]; then
        pgrep -x waybar > /dev/null || waybar &
    else
        sleep $HIDE_DELAY
        Y=$(hyprctl cursorpos | cut -d',' -f2)
        if [ "$Y" -ge "$WAYBAR_HEIGHT" ]; then
            pkill waybar
        fi
    fi

    sleep 0.1
done
