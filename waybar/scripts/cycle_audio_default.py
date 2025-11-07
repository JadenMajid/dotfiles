#!/usr/bin/python3
#Copyright 2025 fsantand
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


import sys
import subprocess

"""
Wireplumber sink/source switcher

It lets you pass your sinks/sources into a dmenu dropdown
for ease of access

Usage:
./wireplumber_audio_switcher.py <Sinks|Sources>
"""

GROUP_DELIMITER = " ├─"
ITEM_DELIMITER  = " │  "
ACCEPTED_GROUPS = set(["Sinks:", "Sources:"])

def clean_line(line: str):
    line = line.replace(GROUP_DELIMITER, "").replace(ITEM_DELIMITER, "").replace(":", "")
    vol_index = line.find("[")
    if vol_index > 0:
        line = line[:vol_index]
    if "*" in line:
        line = line.replace("*", "")
        splitted = line.split(".")
        splitted[1] = f"<b>{splitted[1].strip()} *</b>"
        line = ". ".join(splitted)
    return line.strip()

def parse_wpctl_status():
    found_audio_tab = False
    current_subgroup = None
    processed_data = {}
    output = subprocess.run(
        "wpctl status -k",
        shell=True,
        encoding="utf-8",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )

    for line in output.stdout.split("\n"):
        if not found_audio_tab and line == "Audio":
            found_audio_tab = True

        elif found_audio_tab:
            if line == "":
                found_audio_tab = False
                break
            elif line == ITEM_DELIMITER:
                current_subgroup = None
                continue
            elif line.startswith(GROUP_DELIMITER):
                current_subgroup = clean_line(line)
                processed_data[current_subgroup] = []
                continue
            elif current_subgroup and line.startswith(ITEM_DELIMITER):
                processed_data[current_subgroup].append(clean_line(line))
                continue
    return processed_data

def pipe_into_dmenu(output):
    output = subprocess.run(
        f"echo '{output}' | rofi -dmenu -markup-rows",
        shell=True,
        encoding="utf-8",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )

    if output.returncode != 0:
        return None
    return output.stdout

output = parse_wpctl_status()
sink = pipe_into_dmenu("\n".join(output[sys.argv[1]]))

if sink:
    sink_id = sink.split(".")[0]
    subprocess.run(
        f"wpctl set-default {sink_id}",
        shell=True
    )
