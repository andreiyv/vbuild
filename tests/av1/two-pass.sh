echo Currently disabled
exit
ffmpeg -y -i ../mountains.mp4 -c:v libaom-av1 -strict -2 -b:v 3000K -g 48 -keyint_min 48 -sc_threshold 0 -tile-columns 1 -tile-rows 0 -threads 8 -cpu-used 8 -pass 1 -f matroska NULL

ffmpeg -i ../mountains.mp4 -c:v libaom-av1 -strict -2 -b:v 3000K -maxrate 6000K -bufsize 3000k -g 48 -keyint_min 48 -sc_threshold 0 -tile-columns 1 -tile-rows 0 -threads 8 -cpu-used 5 -pass 2 maountains.mkv

