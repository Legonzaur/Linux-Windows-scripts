#!/bin/bash
target_video_size_MB=23
file=$1
origin_duration_s=$(ffprobe -v error -show_streams -select_streams a "$file" | grep -Po "(?<=^duration\=)\d*\.\d*")
origin_audio_bitrate_kbit_s=$(ffprobe -v error -pretty -show_streams -select_streams a "$file" | grep -Po "(?<=^bit_rate\=)\d*\.\d*")
target_audio_bitrate_kbit_s=128
target_video_bitrate_kbit_s=$(\
    awk \
    -v size="$target_video_size_MB" \
    -v duration="$origin_duration_s" \
    -v audio_rate="$target_audio_bitrate_kbit_s" \
    'BEGIN { print  ( ( size * 8192.0 ) / ( 1.048576 * duration ) - audio_rate ) }')
	ffmpeg \
	-hwaccel cuda \
	-hwaccel_output_format cuda \
    	-i "$file" \
	-preset:v slow \
	-profile:v high \
	-tune:v hq \
	-2pass true \
	-multipass fullres \
	-vf scale_cuda=-2:720 \
    -c:v h264_nvenc \
    -b:v "$target_video_bitrate_kbit_s"k \
    -c:a aac \
    -b:a "$target_audio_bitrate_kbit_s"k \
    "${file%.*}-${target_video_size_MB}mB-nvenc720.mp4"
	
