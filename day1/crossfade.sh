#!/usr/bin/bash

set -eux

# Download source videos
VID_1="Waves.webm"
if [ ! -e "$VID_1" ]
then
    yt-dlp https://www.youtube.com/watch?v=fG_X-cx5Szg
    mv "Flying over Florida _ Relaxing 4K Ocean Videos _ Slowmo Overhead Waves [fG_X-cx5Szg].webm" "$VID_1"

    # Splice out 20 good seconds
    ffmpeg -ss 00:00:01 -i "$VID_1" -t 00:00:20 -vf scale=1920:1080 -an vid1_1080_20s.mp4
fi

VID_2="Hummingbirds.webm"
if [ ! -e "$VID_2" ]
then
    yt-dlp https://www.youtube.com/watch?v=RtUQ_pz5wlo
    mv "See Hummingbirds Fly, Shake, Drink in Amazing Slow Motion _ National Geographic [RtUQ_pz5wlo].webm" "Hummingbirds.webm"

    # Splice out 20 good seconds
    ffmpeg -ss 00:00:24.2 -i "$VID_2" -t 00:00:20 -an vid2_1080_20s.mp4
fi


if false
then
    echo "Splitting frames out from 20s videos"
    mkdir -p "frames_wave" "frames_hummingbird"
    time ffmpeg -i "vid1_1080_20s.mp4" -filter:v fps=30 "frames_wave/%0d.jpg"
    time ffmpeg -i "vid2_1080_20s.mp4" -filter:v fps=30 "frames_hummingbird/%0d.jpg"
fi

TOTAL_FRAMES=600

function threshold() {
    echo "Thresholding $1 with Fred's wonderful scripts"
    # http://www.fmwconcepts.com/imagemagick/ptilethresh/index.php
    mkdir -p "threshold"

    for f in `seq 1 $TOTAL_FRAMES`; do
        percent=$(bc <<< "scale=2; $f * 100 / $TOTAL_FRAMES")
        ptilethresh -p $percent $1/$f.jpg threshold/$f.jpg

    done
}

function merge() {
    echo "Merging $1 * threshold over $2"

    mkdir -p "merged"
    rm -f merged/*.jpg
    for f in `seq 1 $TOTAL_FRAMES`; do
        # Things to try
        #   - Only randomness (every X frames)
        #   - Blend randomness + constant ptile
        #   - lighten / darken

        # Add some randomness every X frames
        if [ $(($f % 10)) -eq 1 ]
        then
            perlin 192x108 noise.png > /dev/null
            convert -resize 1920x1080 noise.png noise.png
        fi

        # See
        # https://legacy.imagemagick.org/Usage/masking/#masked_compose
        # https://legacy.imagemagick.org/Usage/layers/#evaluate-sequence
        # https://legacy.imagemagick.org/Usage/transform/#evaluate

        # I gave up on doing this as one step because it seems impossible
        # Blend noises
        convert threshold/$f.jpg -compose Lighten noise.png -composite temp.png
        # Under, Over, Mask => Output
        convert $2/$f.jpg $1/$f.jpg temp.png -composite merged/$f.jpg
    done

    rm -f "noise.png" "temp.png"
}


if true
then
    set +x
    time threshold frames_hummingbird
    time merge frames_hummingbird frames_wave
    set -x
    ffmpeg -hide_banner -stats -loglevel warning  -y -framerate 30 -start_number 1 -i merged/%d.jpg -c:v libx264 bird_over_waves.mp4

    set +x
    threshold frames_hummingbird
    merge frames_hummingbird frames_wave
    set -x
    ffmpeg -hide_banner -stats -loglevel warning  -y -framerate 30 -start_number 1 -i merged/%d.jpg -c:v libx264 waves_over_bird.mp4
fi
