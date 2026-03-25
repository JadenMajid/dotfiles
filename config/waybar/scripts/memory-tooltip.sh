#!/bin/bash

# Get memory info
read total used <<<$(free -h | awk '/Mem:/ {print $2, $3}' | sed 's/Gi/GB/g')
percent=$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')

# Prepare top 5 memory-consuming processes
top_mem=$(
  ps -eo pid,comm,rss --sort=-rss |
    awk '
    NR==1 {printf "%-8s %-20s %6s\n", "PID", "COMMAND", "MB"; next}
    {rssmb=$3/1024} rssmb>=0.01 {printf "%-8s %-20s %6.1f\n", $1, $2, rssmb}
  ' |
    head -n 10
)

# Escape newlines for JSON
escaped_top_mem=$(echo "$top_mem" | sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/"/\\"/g')

# Output JSON
echo "{\"text\":\"$used/$total (${percent}%)\",\"tooltip\":\"$escaped_top_mem\"}"
