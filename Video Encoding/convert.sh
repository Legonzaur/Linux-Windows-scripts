ffmpeg -i input.mp4 -c:v libx264 -pix_fmt yuv420p -s 1280x720 -crf 25 -c:a copy -ac 2 -b:a 128K -acodec aac output.mp4
