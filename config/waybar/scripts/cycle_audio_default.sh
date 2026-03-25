#!/bin/bash
# Author: Ruben Lopez (Logon84) <rubenlogon@yahoo.es>
# Description: A shell script to switch pipewire sinks (outputs).
# Modified: Removed DBus notifications.

SINKS_TO_SKIP=("easyeffects_sink")

# Create a single regex pattern from the array elements
SKIP_PATTERN=$(
  IFS="|"
  echo "${SINKS_TO_SKIP[*]}"
)

# Create array of sink names to switch to
declare -a SINKS_TO_SWITCH=($(wpctl status -n | grep -zoP '(?<=Sinks:)(?s).*?(?=├─)' | grep -a "vol:" | sed 's/[│*]//g' | awk '{print $2}' | grep -Ev "$SKIP_PATTERN"))

SINK_ELEMENTS=${#SINKS_TO_SWITCH[@]}

# Exit if no sinks are available after filtering
if [ "$SINK_ELEMENTS" -eq 0 ]; then
  exit 1
fi

# Get current sink name and array position
ACTIVE_SINK_NAME=$(wpctl status -n | grep -zoP '(?<=Sinks:)(?s).*?(?=├─)' | grep -a '*' | sed 's/[│*]//g' | awk '{print $2}')
ACTIVE_ARRAY_INDEX=$(echo ${SINKS_TO_SWITCH[@]/$ACTIVE_SINK_NAME//} | cut -d/ -f1 | wc -w | tr -d ' ')

# Get next array name and then its ID to switch to
NEXT_ARRAY_INDEX=$((($ACTIVE_ARRAY_INDEX + 1) % $SINK_ELEMENTS))
NEXT_SINK_NAME=${SINKS_TO_SWITCH[$NEXT_ARRAY_INDEX]}
NEXT_SINK_ID=$(wpctl status -n | grep -zoP '(?<=Sinks:)(?s).*?(?=├─)' | grep -a "$NEXT_SINK_NAME" | sed 's/[│*]//g' | awk '{print int($1)}')

# Switch to sink
wpctl set-default $NEXT_SINK_ID
