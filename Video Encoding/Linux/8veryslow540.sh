#!/bin/bash
target_video_size_MB=8
file=$1
origin_duration_s=$(ffprobe.exe -v error -show_streams -select_streams a "$file" | grep -Po "(?<=^duration\=)\d*\.\d*")
origin_audio_bitrate_kbit_s=$(ffprobe.exe -v error -pretty -show_streams -select_streams a "$file" | grep -Po "(?<=^bit_rate\=)\d*\.\d*")
#target_audio_bitrate_kbit_s=$origin_audio_bitrate_kbit_s # TODO for now, make audio bitrate the same
target_audio_bitrate_kbit_s=128
target_video_bitrate_kbit_s=$(\
    awk \
    -v size="$target_video_size_MB" \
    -v duration="$origin_duration_s" \
    -v audio_rate="$target_audio_bitrate_kbit_s" \
    'BEGIN { print  ( ( size * 8192.0 ) / ( 1.048576 * duration ) - audio_rate ) }')
	ffmpeg.exe \
    -y \
    -i "$file" \
	-preset veryslow \
	-profile:v high \
	-vf scale=-2:540 \
    -c:v libx264 \
    -b:v "$target_video_bitrate_kbit_s"k \
	-passlogfile "${file}-540pass.log"\
    -pass 1 \
    -an \
    -f mp4 \
    NUL \
&& \
	ffmpeg.exe \
    -i "$file" \
	-preset veryslow \
	-profile:v high \
	-vf scale=-2:540 \
    -c:v libx264 \
    -b:v "$target_video_bitrate_kbit_s"k \
    -pass 2 \
    -c:a aac \
	-passlogfile "${file}-540pass.log"\
    -b:a "$target_audio_bitrate_kbit_s"k \
    "${file%.*}-${target_video_size_MB}mB-540.mp4"
	
rm "${file}-540pass.log-0.log"
rm "${file}-540pass.log-0.log.mbtree"