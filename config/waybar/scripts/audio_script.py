#!/usr/bin/env python3
import subprocess
import json
import argparse
import html  # Added for escaping special characters

def get_playerctl_output(command):
    """Helper to run playerctl commands and return stripped output."""
    try:
        return subprocess.check_output(
            ["playerctl"] + command,
            stderr=subprocess.DEVNULL
        ).decode("utf-8").strip()
    except subprocess.CalledProcessError:
        return ""

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--player", default="chromium", help="Player name or pattern")
    args = parser.parse_args()

    player_arg = args.player
    
    status = get_playerctl_output(["-p", player_arg, "status"]).lower()
    
    if not status:
        status = get_playerctl_output(["status"]).lower()
        if not status:
            print(json.dumps({"text": "", "class": "stopped"}))
            return
        player_arg = "" 

    p_flag = ["-p", player_arg] if player_arg else []
    
    # Fetch and ESCAPE the metadata to prevent Pango markup errors
    title = html.escape(get_playerctl_output(p_flag + ["metadata", "title"]))
    artist = html.escape(get_playerctl_output(p_flag + ["metadata", "artist"]))
    
    # 󰏤 = Pause, 󰐊 = Play
    icon = "󰏤" if status == "playing" else "󰐊"
    
    if not title and not artist:
        display_text = f"{icon} Streaming..."
    else:
        display_text = f"{icon} {title} - {artist}" if artist else f"{icon} {title}"

    output = {
        "text": display_text,
        "tooltip": f"Source: {player_arg if player_arg else 'Default'}\nStatus: {status.capitalize()}",
        "class": status
    }

    print(json.dumps(output))

if __name__ == "__main__":
    main()
