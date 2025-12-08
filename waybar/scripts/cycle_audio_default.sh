#!/bin/bash
# Author: Ruben Lopez (Logon84) <rubenlogon@yahoo.es>
# Description: A shell script to switch pipewire sinks (outputs).

# --- FIX 1: Join skip sinks into a single regex pattern ---
# Add sink names (separated with '|') to SKIP while switching with this script.
# Choose names to skip from the output of this command:
# wpctl status -n | grep -zoP '(?<=Sinks:)(?s).*?(?=├─)' | grep -a "vol:"
# Example: SINKS_TO_SKIP=("Monitor Aux" "Speakers")
# If no skip names are added, this script will switch between every available audio sink (output).
SINKS_TO_SKIP=("easyeffects_sink")

# Define Aliases (OPTIONAL)
ALIASES="alsa_output.pci-0000_2b_00.4.analog-stereo:Speakers\nbluez_output.80_99_E7_DF_CE_14.1:XM4 Bluetooth\nalsa_output.pci-0000_29_00.1.hdmi-stereo:Monitor Aux\n"

# Create a single regex pattern from the array elements
SKIP_PATTERN=$(
  IFS="|"
  echo "${SINKS_TO_SKIP[*]}"
)

# Create array of sink names to switch to
# The FIX is to use the constructed $SKIP_PATTERN inside grep -Ev
declare -a SINKS_TO_SWITCH=($(wpctl status -n | grep -zoP '(?<=Sinks:)(?s).*?(?=├─)' | grep -a "vol:" | tr -d \* | awk '{print ($3)}' | grep -Ev "$SKIP_PATTERN"))

# --- FIX 2: Define the SINK_ELEMENTS variable ---
SINK_ELEMENTS=${#SINKS_TO_SWITCH[@]}

# Exit if no sinks are available after filtering
if [ "$SINK_ELEMENTS" -eq 0 ]; then
  echo "No audio sinks available to switch to."
  exit 1
fi

# Get current sink name and array position
# NOTE: The current awk command returns the sink name (the 4th field).
ACTIVE_SINK_NAME=$(wpctl status -n | grep -zoP '(?<=Sinks:)(?s).*?(?=├─)' | grep -a '*' | awk '{print ($4)}')

# Check if the active sink is in the SINKS_TO_SWITCH array. If it's a skipped sink,
# we need to start the index check from 0 (or simply ensure the index calculation works).
# The current method of finding the index is a bit clunky but works by counting words:
# Replace the active name with nothing (//) and count the number of words before the replacement point.
ACTIVE_ARRAY_INDEX=$(echo ${SINKS_TO_SWITCH[@]/$ACTIVE_SINK_NAME//} | cut -d/ -f1 | wc -w | tr -d ' ')

# Get next array name and then its ID to switch to
# $SINK_ELEMENTS is now defined.
NEXT_ARRAY_INDEX=$((($ACTIVE_ARRAY_INDEX + 1) % $SINK_ELEMENTS))
NEXT_SINK_NAME=${SINKS_TO_SWITCH[$NEXT_ARRAY_INDEX]}
# Next sink ID is the 2nd field of the line where $NEXT_SINK_NAME appears
NEXT_SINK_ID=$(wpctl status -n | grep -zoP '(?<=Sinks:)(?s).*?(?=├─)' | grep -a "$NEXT_SINK_NAME" | awk '{print ($2+0)}')

# Switch to sink & notify
wpctl set-default $NEXT_SINK_ID

# 1. Close the previous notification (optional, but good practice)
# Use a simple 'cat' approach to read the ID if it exists
PREV_ID=$(cat /tmp/sss.id 2>/dev/null)
if [ -n "$PREV_ID" ]; then
  gdbus call --session \
    --dest org.freedesktop.Notifications \
    --object-path /org/freedesktop/Notifications \
    --method org.freedesktop.Notifications.CloseNotification \
    "uint32 $PREV_ID" 2>/dev/null
fi

# 2. Get the Alias (or use the Sink Name if no alias is defined)
# Note: Added double quotes around $NEXT_SINK_NAME for robustness against spaces
ALIAS=$(echo -e "$ALIASES" | grep "$NEXT_SINK_NAME" | awk -F ':' '{print ($2)}')

# Determine the final text for the notification body
# If ALIAS is empty, use the raw NEXT_SINK_NAME
if [ -z "$ALIAS" ]; then
  NOTIFICATION_TEXT="Switching to\n($NEXT_SINK_NAME)"
else
  NOTIFICATION_TEXT="Switching to\n($ALIAS)"
fi

# 3. Send the new notification
# The gdbus command needs to be on a single line for simple execution,
# and it's cleaner to handle the argument types directly rather than relying on
# sed to clean up the output afterwards.
# 'sss' -> sender name, notification title, notification body
# '[]'  -> actions (empty array)
# '{}'  -> hints (empty dictionary)
# '5000' -> timeout in milliseconds (uint32)
NEW_ID=$(gdbus call --session \
  --dest org.freedesktop.Notifications \
  --object-path /org/freedesktop/Notifications \
  --method org.freedesktop.Notifications.Notify \
  "" \
  "uint32 0" \
  "gtk-dialog-info" \
  "Audio Switcher" \
  "$NOTIFICATION_TEXT" \
  "[]" \
  "{}" \
  "int32 5000" | grep -oP '(?<=uint32 )\d+')

# Save the new ID for the next run
echo "$NEW_ID" >/tmp/sss.id 2>/dev/null
