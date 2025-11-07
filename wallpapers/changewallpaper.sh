#!/bin/bash
set -euo pipefail
# check if no options passed
helpmessage="Usage: $0 [-f <file> abs or rel] [-s script path]"
# Process management
storedPSIdPath="$HOME/.cache/backgroundscript/psid"
mkdir -p "$(dirname "$storedPSIdPath")"

delete_old_process() {
  [[ -f "$storedPSIdPath" ]] && kill "$(cat "$storedPSIdPath")" 2>/dev/null || true
  rm -f "$storedPSIdPath"
}

store_new_process() {
  echo "$1" >"$storedPSIdPath"
}

# Option handling
while getopts "hfs:" flag; do
  case "$flag" in
  h)
    echo "$helpmessage" && exit
    ;;
  f)
    # Check path argument
    if [[ "$2" != /* ]]; then
      cd "$(dirname "$0")" || {
        echo "passed file directory invalid!"
        exit 1
      }
    fi
    if [[ -f "$2" ]]; then
      delete_old_process
      echo "Changing wallpaper to $2"
      rm -f ~/.config/wallpapers/wallpaper
      ln -s "$2" ~/.config/wallpapers/wallpaper

      # Start hyprpaper and store pid
      printf "\n"
      hyprpaper &
      pid=$! && echo "Success! Changed wallpaper to $2"
      disown
      store_new_process "$pid"

    else
      echo "Passed file does not exist!"
      exit 1
    fi
    ;;
  s)
    delete_old_process
    printf "\n"
    kitten panel --edge=background "$2" &
    pid=$! && echo "Success! Changed wallpaper to $2"
    disown
    store_new_process "$pid"

    ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    exit 1
    ;;
  esac
done
echo | command
