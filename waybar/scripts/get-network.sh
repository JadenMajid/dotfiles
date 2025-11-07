#!/usr/bin/env bash

IFACE="enp37s0"

STATS=$(ifstat "$IFACE" 1 1 2>/dev/null | tail -n 2 | head -n 1 | awk '{print $1, $2}')

if [[ -z "$STATS" ]]; then
  DOWN=0
  UP=0
else
  read UP DOWN <<<"$STATS"
  DOWN=$(awk "BEGIN {printf \"%.2f\", $DOWN/1024}")
  UP=$(awk "BEGIN {printf \"%.2f\", $UP/1024}")
fi

# Output JSON with text and tooltip
echo "{\"text\": \"${DOWN}   ${UP}  \", \"tooltip\": \"Down: ${DOWN} MB/s\\nUp: ${UP} MB/s\"}"
