#!/bin/bash
target_video_size_MB=50
file="input.mp4"
origin_duration_s=$(ffprobe.exe -v error -show_streams -select_streams a "$file" | grep -Po "(?<=^duration\=)\d*\.\d*")
origin_audio_bitrate_kbit_s=$(ffprobe.exe -v error -pretty -show_streams -select_streams a "$file" | grep -Po "(?<=^bit_rate\=)\d*\.\d*")
target_audio_bitrate_kbit_s=$origin_audio_bitrate_kbit_s # TODO for now, make audio bitrate the same
target_video_bitrate_kbit_s=$(\
    awk \
    -v size="$target_video_size_MB" \
    -v duration="$origin_duration_s" \
    -v audio_rate="$target_audio_bitrate_kbit_s" \
    'BEGIN { print  ( ( size * 8192.0 ) / ( 1.048576 * duration ) - audio_rate ) }')
	ffmpeg.exe \
    -y \
    -i "$file" \
    -c:v libx264 \
    -b:v "$target_video_bitrate_kbit_s"k \
    -pass 1 \
    -an \
    -f mp4 \
    NUL \
&& \
ffmpeg.exe \
    -i "$file" \
    -c:v libx264 \
    -b:v "$target_video_bitrate_kbit_s"k \
    -pass 2 \
    -c:a aac \
    -b:a "$target_audio_bitrate_kbit_s"k \
    "${file%.*}-${target_video_size_MB}mB.mp4"
	
rm "ffmpeg2pass-0.log"
rm "ffmpeg2pass-0.log.mbtree"