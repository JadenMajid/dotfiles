#!/bin/bash

# 1. Start hyprlock as a foreground, blocking process.
hyprlock &

# Capture the Process ID (PID) of the running hyprlock instance
LOCK_PID=$!

# 2. Give hyprlock a moment to initialize and draw the lockscreen.
sleep 0.1

# 3. Turn off the display (DPMS off) while the screen is locked.
hyprctl dispatch dpms off

# 4. Wait for hyprlock to exit (i.e., wait until the user unlocks the screen).
wait $LOCK_PID

# 5. Turn the display back on (DPMS on) right after hyprlock exits.
hyprctl dispatch dpms on

# Optional: Add a small delay after turning the screen on.
# sleep 0.1
