file=$1
ffmpeg.exe -i "$file" -c:v libx264 -pix_fmt yuv420p -preset veryslow -vf scale=-2:720 -b:v 8M -c:a copy "${file%.*}-8Mbps-720.mp4"