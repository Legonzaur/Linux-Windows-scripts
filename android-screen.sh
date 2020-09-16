$(xrandr --output HDMI-1 --mode 1280x720_60.00 --pos 1920x500 &&
ffmpeg -f x11grab -video_size 1280x720 -i :0.0+1920,500 -framerate 60 -tune:v fastdecode+zerolatency -preset:v ultrafast -crf 0 -vcodec libx264rgb -f mpegts "tcp://127.0.0.1:8888?listen" 2> /dev/null ||
xrandr --auto --output HDMI-1 --off) &

sleep 1 &&
adb reverse tcp:8888 tcp:8888 &&
adb shell am start -d "tcp://127.0.0.1:8888" -a android.intent.action.VIEW
