#!/usr/bin/env bash

IFACE="enp37s0"
HISTORY_FILE_DOWN="/tmp/${IFACE}_down_history"
HISTORY_FILE_UP="/tmp/${IFACE}_up_history"
MAX_POINTS=40
BLOCKS=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)

# Read previous history
readarray -t HISTORY_DOWN < <(cat "$HISTORY_FILE_DOWN" 2>/dev/null || echo "")
readarray -t HISTORY_UP < <(cat "$HISTORY_FILE_UP" 2>/dev/null || echo "")

# Get instantaneous network speeds
#STATS = {printf "Download %.0f KB/s Upload %.0f KB/s\n" $(ifstat 1 1 | tail -n1)}
#STATS= {printf "Down=%.0fKB Up=%.0fKB", $1/1024, $2/1024}
STATS=$(ifstat "$IFACE" 1 1 2>/dev/null | tail -n 2 | head -n 1 | awk '{print $1, $2}')

if [[ -z "$STATS" ]]; then
  UP=0
  DOWN=0
else
  read UP DOWN <<<"$STATS"
  DOWN=$(awk "BEGIN {printf \"%.2f\", $DOWN/1000}")
  UP=$(awk "BEGIN {printf \"%.2f\", $UP/1000}")
fi

# Update history
HISTORY_DOWN+=($DOWN)
HISTORY_UP+=($UP)
if [[ ${#HISTORY_DOWN[@]} -gt $MAX_POINTS ]]; then
  HISTORY_DOWN=("${HISTORY_DOWN[@]:1}")
  HISTORY_UP=("${HISTORY_UP[@]:1}")
fi

# Save history
printf "%s\n" "${HISTORY_DOWN[@]}" >"$HISTORY_FILE_DOWN"
printf "%s\n" "${HISTORY_UP[@]}" >"$HISTORY_FILE_UP"

# Find max for scaling
MAX_DOWN=$(printf "%s\n" "${HISTORY_DOWN[@]}" | sort -nr | head -n1)
MAX_DOWN=$(awk "BEGIN {print ($MAX_DOWN>0)?$MAX_DOWN:1}")
MAX_UP=$(printf "%s\n" "${HISTORY_UP[@]}" | sort -nr | head -n1)
MAX_UP=$(awk "BEGIN {print ($MAX_UP>0)?$MAX_UP:1}")

# Generate sparkline
SPARKLINE_DOWN=""
SPARKLINE_UP=""
for i in "${!HISTORY_DOWN[@]}"; do
  INDEX_DOWN=$(awk -v val="${HISTORY_DOWN[i]}" -v max="$MAX_DOWN" 'BEGIN{i=int(val/max*7+0.5); if(i>7)i=7; print i}')
  INDEX_UP=$(awk -v val="${HISTORY_UP[i]}" -v max="$MAX_UP" 'BEGIN{i=int(val/max*7+0.5); if(i>7)i=7; print i}')
  SPARKLINE_DOWN+="${BLOCKS[$INDEX_DOWN]}"
  SPARKLINE_UP+="${BLOCKS[$INDEX_UP]}"
done

# Escape tooltip
ESCAPED_TOOLTIP=$(printf 'Down: %s MB/s\n%s\n\nUp: %s MB/s\n%s' "$DOWN" "$SPARKLINE_DOWN" "$UP" "$SPARKLINE_UP" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')

# Output JSON
echo "{\"text\": \"${DOWN}   ${UP} \", \"tooltip\": ${ESCAPED_TOOLTIP}}"
