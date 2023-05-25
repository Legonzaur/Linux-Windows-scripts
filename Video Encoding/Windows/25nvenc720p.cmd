@echo off

SET target_video_size_MB=22

for /f %%i in ('ffprobe -v error -show_entries "format=duration" -of "default=noprint_wrappers=1:nokey=1" "%~1"') do set origin_duration_s=%%i

for /f %%i in ('ffprobe -v error -select_streams a:0 -show_entries "stream=bit_rate" -of "default=noprint_wrappers=1:nokey=1" "%~1"') do set origin_audio_bitrate=%%i

IF "%origin_audio_bitrate%"=="N/A" SET origin_audio_bitrate=134144

for /f %%i in ('powershell "[math]::Ceiling(%origin_duration_s%*%origin_audio_bitrate%)"') do set target_audio_size=%%i

for /f %%i in ('powershell "[math]::Floor(((%target_video_size_MB%*8786432)-%target_audio_size%)/%origin_duration_s%)"') do set target_video_bitrate_kbit_s=%%i

SET file=%~1
SET bv=%target_video_bitrate_kbit_s%
SET output=%~1-25mb-nvenc-720p.mp4
SET args=-vf scale=-2:720

ffmpeg -hwaccel auto -i "%file%" -preset:v hq -tune hq -profile:v high -rc vbr_hq -2pass true -rc-lookahead 32 %args% -c:v h264_nvenc -b:v %bv% -c:a copy -map 0:v:0 -map 0:a:0 "%output%"