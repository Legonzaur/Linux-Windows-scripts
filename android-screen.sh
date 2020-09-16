###CONFIGURATION###

#Initial IP address and port when no IP address is given
IPADDR="127.0.0.1:8888"

#Height of the virtual screen
VIRTXRES=720

#Width of the virtual screen
VIRTYRES=1400

#Height offset of the virtual screen
OFFSETX=500

#Width offset of the virtual screen
OFFSETY=1920



###SCRIPT###
if [ -n "$1" ];
then
    IPADDR=$1
fi

Xmode=${VIRTYRES}x${VIRTXRES}_60.00

xrandr --newmode $(gtf ${VIRTYRES} ${VIRTXRES} 60 | sed -ne 's/"//g;s/ Modeline //p')
xrandr --addmode HDMI-1 "$Xmode"

$(xrandr --output HDMI-1 --mode $Xmode --pos ${OFFSETY}x${OFFSETX} &&
ffmpeg -probesize 32 -analyzeduration 0 -nostdin -hwaccel cuda -hwaccel_output_format cuda -framerate 60 -f x11grab -video_size ${VIRTYRES}x${VIRTXRES} -i :0.0+${OFFSETY},${OFFSETX} -framerate 60 -flags low_delay -fflags nobuffer+fastseek+flush_packets -strict experimental -tune:v fastdecode+zerolatency -analyzeduration 0 -threads auto -preset:v ultrafast -crf 0 -vcodec libx264rgb -f mpegts "tcp://${IPADDR}?listen" 2> /dev/null ||
xrandr --auto --output HDMI-1 --off) &

#if [ -a "$1" ]
#then
    sleep 1 &&
    adb reverse tcp:8888 tcp:8888 &&
    adb shell am start -d "tcp://${IPADDR}" -a android.intent.action.VIEW
#fi
