#!/bin/bash

# Find any player that is currently Playing
playing_player=$(playerctl --list-all 2>/dev/null | while read -r p; do
    if playerctl --player="$p" status 2>/dev/null | grep -q "Playing"; then
        echo "$p"
        exit 0
    fi
done)

# If nothing is playing
if [ -z "$playing_player" ]; then
    echo "[ -------------------- ] "
    exit 0
fi

# Get position (in seconds, integer part) and length (in microseconds)
pos_sec=$(playerctl --player="$playing_player" position 2>/dev/null | cut -d'.' -f1)
length_us=$(playerctl --player="$playing_player" metadata mpris:length 2>/dev/null)

# If we can't get valid duration or position
if [ -z "$pos_sec" ] || [ -z "$length_us" ] || [ "$length_us" -eq 0 ]; then
    echo "[ -------------------- ] --:--"
    exit 0
fi

# Convert length to seconds
length_sec=$(( length_us / 1000000 ))

# Build progress bar (20 blocks)
bar_length=20
progress=$(( pos_sec * bar_length / length_sec ))
bar=$(printf '▓%.0s' $(seq 1 $progress))      # filled part
bar+=$(printf '─%.0s' $(seq 1 $((bar_length - progress))))  # empty part

# Format time as MM:SS
format_time() {
    printf "%02d:%02d" $(( $1 / 60 )) $(( $1 % 60 ))
}

current=$(format_time "$pos_sec")
total=$(format_time "$length_sec")

# Final output
echo "[ $bar ] $current / $total"
