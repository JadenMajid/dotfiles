#!/bin/bash

cd ~/.config/wallpapers || exit

# Remove the old symlink if it exists
rm -f wallpaper

# Select a random file that is not a .sh script
paper=$(find . -maxdepth 1 -type f ! -name "*.sh" | shuf -n 1)

# Create a new symlink named 'wallpaper' pointing to the selected file
ln -s "$paper" wallpaper
pkill hyprpaper
hyprpaper &
disown
