#!/bin/bash
file=$1
	ffmpeg.exe \
    -i "$file" \
	-c copy \
    -c:v copy \
    -an \
    "${file%.*}-nosound.mp4"
	