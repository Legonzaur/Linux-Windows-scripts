#!/bin/bash
file=$1
	ffmpeg.exe \
    -i "$file" \
	-preset:v veryslow \
	-profile:v high \
	-pix_fmt yuv420p \
	-vf scale=-2:720 \
    -c:v libx264 \
	-b:v 5M \
    -c:a copy \
    "${file%.*}-5Mbps-720.mp4"
	