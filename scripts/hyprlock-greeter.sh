#!/bin/bash
# Get the name of a currently playing player (if any)
playing_player=$(playerctl --list-all 2>/dev/null | while read -r p; do
    if playerctl --player="$p" status 2>/dev/null | grep -q "Playing"; then
        echo "$p"
        exit 0
    fi
done)

if [ -n "$playing_player" ]; then
    # Get metadata from the playing player
    song=$(playerctl --player="$playing_player" metadata title 2>/dev/null || echo "Unknown")
    artist=$(playerctl --player="$playing_player" metadata artist 2>/dev/null)

    # Check if the player is Spotify or ncspot
    if echo "$playing_player" | grep -qiE "spotify|ncspot"; then
        icon=""
    else
        icon=""
    fi

    if [ -n "$artist" ]; then
        echo "$icon $artist — $song"
    else
        # No artist metadata (common for YouTube videos, local files, etc.)
        echo "$icon $song"
    fi
else
    hour=$(date +"%H")
    if [ "$hour" -ge 5 ] && [ "$hour" -lt 12 ]; then
        echo "Good morning, $USER"
    elif [ "$hour" -ge 12 ] && [ "$hour" -lt 17 ]; then
        echo "Good afternoon, $USER"
    else
        echo "Good evening, $USER"
    fi
fi
