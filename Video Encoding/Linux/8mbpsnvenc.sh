#!/bin/bash
file=$1
	ffmpeg.exe \
    -i "$file" \
	-preset:v p7\
	-profile:v high \
	-tune:v hq \
    -c:v h264_nvenc \
	-b:v 8M \
    -c:a copy \
    "${file%.*}-8Mbps-nvenc.mp4"
	