#!/usr/bin/bash

set -eux

NAME=${1:-out.mp4}
ffmpeg -hide_banner -stats -loglevel warning  -y -framerate 30 -pattern_type glob -i "Render/*.png" -c:v libx264 "$NAME"
