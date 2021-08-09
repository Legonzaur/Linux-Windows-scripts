#!/bin/bash

mkdir -p /tmp/ffmpeg_two_pass

desired_size=90
preset=slower

duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $1)
desired_size=$(($desired_size*8192))
duration=$(perl -w -e "use POSIX; print ceil($duration/1.0), qq{\n}")
(( desired_rate=desired_size/duration ))
desired_rate=${desired_rate}k

ffmpeg -y -i $1 -c:v libx264 -preset $preset -b:v $desired_rate -pass 1 -passlogfile /tmp/ffmpeg_two_pass/$1 -vsync cfr -f null /dev/null && \
ffmpeg -i $1 -c:v libx264 -preset $preset -b:v $desired_rate -pass 2 -passlogfile /tmp/ffmpeg_two_pass/$1 -c:a aac -b:a 128k ${1}-converted.mp4
                                                                  
rm /tmp/ffmpeg_two_pass/${1}-0.log*
