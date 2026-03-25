#!/bin/bash

# Target Cider specifically as the player
PLAYER="cider"
STATUS=$(playerctl -p "$PLAYER" status 2>/dev/null)

if [ "$STATUS" = "Playing" ]; then
    # If playing, show the artist and title
    echo "󰎆 $(playerctl -p "$PLAYER" metadata --format '{{artist}} - {{title}}')"
elif [ "$STATUS" = "Paused" ]; then
    echo "󰏤 Paused"
else
    # If not running or nothing playing
    echo ""
fi
