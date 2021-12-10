#!/bin/bash
target_video_size_MB=7
file=$1
origin_duration_s=$(ffprobe.exe -v error -show_streams -select_streams a "$file" | grep -Po "(?<=^duration\=)\d*\.\d*")
origin_audio_bitrate_kbit_s=$(ffprobe.exe -v error -pretty -show_streams -select_streams a "$file" | grep -Po "(?<=^bit_rate\=)\d*\.\d*")
target_audio_bitrate_kbit_s=128
target_video_bitrate_kbit_s=$(\
    awk \
    -v size="$target_video_size_MB" \
    -v duration="$origin_duration_s" \
    -v audio_rate="$target_audio_bitrate_kbit_s" \
    'BEGIN { print  ( ( size * 8192.0 ) / ( 1.048576 * duration ) - audio_rate ) }')
	ffmpeg.exe \
    -i "$file" \
	-preset:v p7\
	-profile:v high \
	-tune:v hq \
	-2pass true \
	-multipass fullres \
    -c:v h264_nvenc \
    -b:v "$target_video_bitrate_kbit_s"k \
    -c:a aac \
    -b:a "$target_audio_bitrate_kbit_s"k \
    "${file%.*}-${target_video_size_MB}mB-nvenc.mp4"
	