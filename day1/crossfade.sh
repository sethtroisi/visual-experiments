#!/usr/bin/bash

set -eux

# Download source videos
VID_1="Waves.webm"
if [ ! -e "$VID_1" ]
then
    yt-dlp https://www.youtube.com/watch?v=fG_X-cx5Szg
    mv "Flying over Florida _ Relaxing 4K Ocean Videos _ Slowmo Overhead Waves [fG_X-cx5Szg].webm" "$VID_1"

    # Splice out 20 good seconds
    ffmpeg -ss 00:00:01 -i "$VID_1" -t 00:00:20 -an vid1_20s.mp4
fi

VID_2="Hummingbirds.webm"
if [ ! -e "$VID_2" ]
then
    yt-dlp https://www.youtube.com/watch?v=RtUQ_pz5wlo
    mv "See Hummingbirds Fly, Shake, Drink in Amazing Slow Motion _ National Geographic [RtUQ_pz5wlo].webm" "Hummingbirds.webm"

    # Splice out 20 good seconds
    ffmpeg -ss 00:00:24.2 -i "$VID_2" -t 00:00:20 -an vid2_20s.mp4
fi

FPS=25
if [ ! -d "frames_wave"] || [ ! -d "frames_hummingbird" ]
then
    echo "Splitting frames out from 20s videos"
    mkdir -p "frames_wave" "frames_hummingbird"
    # -q:v quality video (jpg 2-31, 31 is worst)
    time ffmpeg -hide_banner -i "vid1_20s.mp4" -filter:v "scale=1920x1080,fps=$FPS" -q:v 4  "frames_wave/%0d.jpg"
    time ffmpeg -hide_banner -i "vid2_20s.mp4" -filter:v "scale=1920x1080,fps=$FPS" -q:v 4  "frames_hummingbird/%0d.jpg"
fi


# TODO min of frames_hummingbird/ and frames_wave/
TOTAL_FRAMES=$(ls frames_hummingbird/ | wc -l)
echo "Found $TOTAL_FRAMES frames"

function threshold() {
    echo "Thresholding $1 with Fred's wonderful scripts"
    # http://www.fmwconcepts.com/imagemagick/ptilethresh/index.php
    mkdir -p "threshold_$1"

    for f in `seq 1 $TOTAL_FRAMES`; do
        percent=$(bc <<< "scale=2; $f * 100 / $TOTAL_FRAMES")
        # output gif per http://www.fmwconcepts.com/imagemagick/ptilethresh/index.php
        ptilethresh -p $percent $1/$f.jpg "threshold_$1"/$f.gif
    done
}

function merge() {
    echo "Merging $1 over $2"

    mkdir -p "merged"
    rm -f merged/*.jpg
    set +x
    for f in `seq 1 $TOTAL_FRAMES`; do
        # Things to try
        #   - Only randomness (every X frames)
        #   - Blend randomness + constant ptile
        #   - Compose {Lighten, Darken}
        #   - perlin -a {0.5, 1, 2, $percent}

        # Add some randomness every X frames
        if [ $(($f % $FPS)) -eq 1 ]
        then
            echo "New noise @ $f"
            # T
            perlin 1920x1080 -a 0.5 noise.png > /dev/null
        fi

        # See
        # https://legacy.imagemagick.org/Usage/masking/#masked_compose
        # https://legacy.imagemagick.org/Usage/layers/#evaluate-sequence
        # https://legacy.imagemagick.org/Usage/transform/#evaluate

        # Blend noises
        #convert threshold/$f.jpg -compose Lighten noise.png -composite temp.png
        # Under, Over, Mask => Output
        #convert $2/$f.jpg $1/$f.jpg temp.png -composite merged/$f.jpg

        # (Under * Black_of_mask) + (Over * White_of_mask) => Output
        convert "$1/$f.jpg" "$2/$f.jpg" \
            \( "threshold_$2/$f.gif" "noise.png" -compose Darken -composite \) \
            -composite "merged/$f.jpg"
    done
    set -x
}


if false
then
    set +x
    time threshold frames_hummingbird
    time threshold frames_wave
    set -x
fi

if true
then
    time merge frames_hummingbird frames_wave
    ffmpeg -hide_banner -stats -loglevel warning  -y -framerate $FPS -start_number 1 -i merged/%d.jpg -c:v libx264 bird_over_waves.mp4

    time merge frames_wave frames_hummingbird
    ffmpeg -hide_banner -stats -loglevel warning  -y -framerate $FPS -start_number 1 -i merged/%d.jpg -c:v libx264 waves_over_bird.mp4
fi
