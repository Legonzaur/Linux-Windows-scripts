@echo off

SET target_video_size_MB=23

for /f %%i in ('ffprobe -v error -show_entries "format=duration" -of "default=noprint_wrappers=1:nokey=1" "%~1"') do set origin_duration_s=%%i

for /f %%i in ('ffprobe -v error -select_streams a:0 -show_entries "stream=bit_rate" -of "default=noprint_wrappers=1:nokey=1" "%~1"') do set origin_audio_bitrate=%%i

IF "%origin_audio_bitrate%"=="N/A" SET origin_audio_bitrate=134144

for /f %%i in ('powershell "[math]::Ceiling(%origin_duration_s%*%origin_audio_bitrate%)"') do set target_audio_size=%%i

for /f %%i in ('powershell "[math]::Floor(((%target_video_size_MB%*8786432)-%target_audio_size%)/%origin_duration_s%)"') do set target_video_bitrate_kbit_s=%%i

SET file=%~1
SET bv=%target_video_bitrate_kbit_s%
SET output=%~1-25mb-libx264
SET args=

ffmpeg -y -hwaccel auto -i "%file%" -c:v libx264 -preset:v slow %args% -passlogfile "%output%" -profile:v high -b:v %bv% -pass 1 -an -f null NIL && ffmpeg -hwaccel auto -i "%file%" -c:v libx264 -preset:v slow %args% -passlogfile "%output%" -profile:v high -b:v %bv% -pass 2 -c:a copy -map 0:v:0 -map 0:a:0 "%output%.mp4"
del "%output%-0.log"
del "%output%-0.log.mbtree"
