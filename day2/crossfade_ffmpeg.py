#!/usr/env python

# Basically my own version of this
# https://trac.ffmpeg.org/wiki/Xfade

import subprocess


EFFECTS = [
    # "custom",
    "fade", "wipeleft", "wiperight", "wipeup",
    "wipedown", "slideleft", "slideright", "slideup", "slidedown",
    "circlecrop", "rectcrop", "distance", "fadeblack", "fadewhite",
    "radial", "smoothleft", "smoothright", "smoothup", "smoothdown",
    "circleopen", "circleclose", "vertopen", "vertclose", "horzopen",
    "horzclose", "dissolve", "pixelize", "diagtl", "diagtr",
    "diagbl", "diagbr", "hlslice", "hrslice", "vuslice",
    "vdslice", "fadegrays",
    # "hblue", "wipetl", "wipetr", "wipebl", "wipebr", # https://trac.ffmpeg.org/ticket/8934
    # "squeezeh", "squeezev", "zoomin",
]

# Set up two 5 second clips from Day 1
# $ ffmpeg -y -ss 00:00:02 -i "../day1/Waves.webm" -t 00:00:5 -an -filter:v "scale=1920x1080,fps=25" vid1_1080_5s.mp4
# $ ffmpeg -y -ss 00:00:25 -i "../day1/Hummingbirds.webm" -t 00:00:5 -an -filter:v "scale=1920x1080,fps=25" vid2_1080_5s.mp4

vid1 = "vid1_1080_5s.mp4"
vid2 = "vid2_1080_5s.mp4"

# Needed while apt ffmpeg < 4.3
ffmpeg_bin = "/snap/bin/ffmpeg"

for effect in EFFECTS:
    filter_cmd = ["-filter_complex", "xfade=transition=" + effect + ":duration=3:offset=1"]

    cmd = [ffmpeg_bin, "-i", vid1, "-i", vid2] + filter_cmd + [effect + ".mp4"]
    print(effect, "\t", " ".join(cmd))
    subprocess.check_output(cmd)
