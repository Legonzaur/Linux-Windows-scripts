ipaddr="127.0.0.1:8888"
if [ -n "$1" ];
then
    ipaddr=$1
fi

virtxres=720
virtyres=1280
Xmode="1280x720_60.00"

$(xrandr --output HDMI-1 --mode $Xmode --pos 1920x500 &&
ffmpeg -f x11grab -video_size ${virtyres}x${virtxres} -i :0.0+1920,500 -framerate 60 -tune:v fastdecode+zerolatency -preset:v ultrafast -crf 0 -vcodec libx264rgb -f mpegts "tcp://${ipaddr}?listen" 2> /dev/null ||
xrandr --auto --output HDMI-1 --off) &

if [ -n "$1" ]
then
    sleep 1 &&
    adb reverse tcp:8888 tcp:8888 &&
    adb shell am start -d "tcp://${ipaddr}" -a android.intent.action.VIEW
fi

#MPV config for low latency : 
#no-cache
#untimed
#no-demuxer-thread
#video-sync=audio
#vd-lavc-threads=1

