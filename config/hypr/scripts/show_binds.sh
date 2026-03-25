#!/usr/bin/env bash
set -euo pipefail

# Dependencies: hyprctl, jq, anyrun

# Get bindings from hyprctl in JSON format
json_binds=$(hyprctl binds -j)

# Use jq to format the bindings for display
formatted_binds=$(echo "$json_binds" | jq -r '.[] | 
    "\(.modmask | if . == 64 then "SUPER" elif . == 65 then "SUPER+SHIFT" else . end) + \(.key) -> \(.dispatcher) \(.arg)"' | 
    sort | uniq)

if [ -z "$formatted_binds" ]; then
    notify-send "Hyprland binds" "No binds found."
    exit 0
fi

# Pipe to anyrun via stdin plugin
echo "$formatted_binds" | anyrun --plugins libstdin.so
