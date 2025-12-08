#!/usr/bin/env bash
set -euo pipefail

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.conf"
MENU_CMD=${MENU_CMD:-"rofi -dmenu -i -p 'Hyprland binds'"}

main_mod=$(awk -F'=' '/^\$mainMod/ {gsub(/#.*/,"",$2); gsub(/^[ \t]+|[ \t]+$/,"",$2); print $2; exit}' "$CONFIG")

bindings=$(awk -v mm="$main_mod" '
function ltrim(s){sub(/^[ \t]+/,"",s);return s}
function rtrim(s){sub(/[ \t]+$/,"",s);return s}
function trim(s){return rtrim(ltrim(s))}
function join(arr,start,end,sep,  i,s){s=arr[start]; for(i=start+1;i<=end;i++) s=s sep arr[i]; return s}
{
    line=$0
    sub(/#.*/,"",line)
    if (line !~ /^[ \t]*bind/) next
    sub(/^[ \t]*/,"",line)
    sub(/[ \t]*=[ \t]*/,"=",line)
    split(line, kv, "=")
    if (length(kv) < 2) next
    body=kv[2]
    n=split(body, parts, ",")
    for(i=1;i<=n;i++) parts[i]=trim(parts[i])
    if (n < 3) next
    trigger=parts[1]
    key=parts[2]
    action=parts[3]
    if (trigger ~ /^\$mainMod/) gsub(/\$mainMod/, mm, trigger)
    combo=(trigger == "" ? key : trigger " + " key)
    desc=(n > 3 ? action " " join(parts, 4, n, ", ") : action)
    printf "%-28s -> %s\n", combo, desc
}
' "$CONFIG")

if [ -z "$bindings" ]; then
    notify-send "Hyprland binds" "No binds found in $CONFIG"
    exit 0
fi

if command -v rofi >/dev/null 2>&1; then
    printf "%s\n" "$bindings" | eval "$MENU_CMD" >/dev/null
else
    printf "%s\n" "$bindings"
fi
