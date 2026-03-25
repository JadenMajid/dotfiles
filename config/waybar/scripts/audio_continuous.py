#!/usr/bin/env python3
import subprocess
import json
import html
import time


def stream_metadata():
    # Target 'chromium' to catch Cider/Electron instances
    cmd = [
        "playerctl",
        "-p",
        "chromium",
        "metadata",
        "--follow",
        "--format",
        '{"status": "{{status}}", "artist": "{{artist}}", "title": "{{title}}"}',
    ]

    last_valid_display = ""
    last_known_status = "stopped"

    while True:
        try:
            process = subprocess.Popen(
                cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True
            )

            # Initial check if player is even running
            if process.poll() is not None:
                print(json.dumps({"text": "", "class": "stopped"}), flush=True)
                time.sleep(2)
                continue

            for line in process.stdout:
                line = line.strip()
                if not line or not line.startswith("{"):
                    continue

                try:
                    data = json.loads(line)
                except json.JSONDecodeError:
                    continue

                status = data.get("status", "").lower()
                raw_artist = data.get("artist", "").strip()
                raw_title = data.get("title", "").strip()

                # Determine the icon based on current status
                icon = "󰏤" if status == "playing" else "󰐊"

                # CASE 1: We have new metadata
                if raw_title:
                    artist_escaped = html.escape(raw_artist)
                    title_escaped = html.escape(raw_title)
                    content = (
                        f"{artist_escaped} - {title_escaped}"
                        if artist_escaped
                        else title_escaped
                    )
                    last_valid_display = content
                    last_known_status = status

                    print(
                        json.dumps({"text": f"{icon} {content}  ", "class": status}),
                        flush=True,
                    )

                # CASE 2: No metadata in this packet, but player is still active
                elif status in ["playing", "paused"]:
                    # If we have a saved track name, keep showing it with the new icon
                    if last_valid_display:
                        print(
                            json.dumps(
                                {
                                    "text": f"{icon} {last_valid_display}",
                                    "class": status,
                                }
                            ),
                            flush=True,
                        )
                    else:
                        # Fallback for the very first launch if metadata hasn't arrived yet
                        print(
                            json.dumps(
                                {"text": f"{icon} Streaming...", "class": status}
                            ),
                            flush=True,
                        )

                # CASE 3: Player stopped
                else:
                    last_valid_display = ""
                    print(json.dumps({"text": "", "class": "stopped"}), flush=True)

            process.stdout.close()
            process.wait()

            # Reset when the process ends (Cider closed)
            last_valid_display = ""
            print(json.dumps({"text": "", "class": "stopped"}), flush=True)
            time.sleep(2)

        except Exception:
            time.sleep(2)


if __name__ == "__main__":
    stream_metadata()
