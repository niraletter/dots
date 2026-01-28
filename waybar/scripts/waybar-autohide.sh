#!/bin/bash
# ~/.config/hypr/scripts/waybar-hover.sh

hyprctl event -p 'mouse' | while read -r event; do
  mouse_y=$(hyprctl cursorpos | cut -d',' -f2)

  if [ "$mouse_y" -lt 5 ]; then
    pkill -SIGUSR1 waybar 2>/dev/null
  else
    pkill -SIGUSR2 waybar 2>/dev/null
  fi
done
