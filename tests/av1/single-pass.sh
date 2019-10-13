echo Currently disabled
exit
ffmpeg -i ../mountains.mp4 -c:v libaom-av1 -crf 24 -strict experimental mountains.mkv -threads 8
