#!/bin/bash
file=$1
	ffmpeg.exe \
    -i "$file" \
	-preset:v p7 \
	-profile:v high \
	-tune:v hq \
	-vf scale=-2:720 \
    -c:v h264_nvenc \
	-b:v 5M \
    -c:a copy \
    "${file%.*}-5Mbps-720-nvenc.mp4"
	