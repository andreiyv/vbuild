ffprobe -i DATASAT_51_71_DTS-HD_MA-thedigitaltheater.mkv 2>&1 | egrep Stream

Stream #0:0: Video: h264 (High), yuv420p(progressive), 1920x1080 [SAR 1:1 DAR 16:9], 23.98 fps, 23.98 tbr, 1k tbn, 47.95 tbc (default)
    Stream #0:1: Audio: dts (DTS-HD MA), 48000 Hz, 5.1(side), s32p (24 bit) (default)
    Stream #0:2: Audio: dts (DTS-HD MA), 48000 Hz, 7.1, s32p (24 bit)
    Stream #0:3: Audio: pcm_s24be, 48000 Hz, 2 channels, s32 (24 bit), 2304 kb/s

ffmpeg -i DATASAT_51_71_DTS-HD_MA-thedigitaltheater.mkv -map 0:0 -c copy stream-0.h264
ffmpeg -i DATASAT_51_71_DTS-HD_MA-thedigitaltheater.mkv -map 0:1 -c copy stream-1.dts
ffmpeg -i DATASAT_51_71_DTS-HD_MA-thedigitaltheater.mkv -map 0:2 -c copy stream-2.dts
ffmpeg -i DATASAT_51_71_DTS-HD_MA-thedigitaltheater.mkv -map 0:3 -c pcm_s24le stream-3.wav

-rw-r--r-- 1 hduser hduser 173882393 дек 31 09:50 stream-0.h264
-rw-r--r-- 1 hduser hduser  28249656 дек 31 09:46 stream-1.dts
-rw-r--r-- 1 hduser hduser  35304080 дек 31 09:50 stream-2.dts
-rw-r--r-- 1 hduser hduser  14698182 дек 31 09:53 stream-3.wav

    Stream #0:0: Video: h264 (High), yuv420p(progressive), 1920x1080 [SAR 1:1 DAR 16:9], 23.98 fps, 23.98 tbr, 1200k tbn, 47.95 tbc
    Stream #0:0: Audio: dts (DTS-HD MA), 48000 Hz, 5.1(side), s32p (24 bit)
    Stream #0:0: Audio: dts (DTS-HD MA), 48000 Hz, 7.1, s32p (24 bit)
    Stream #0:0: Audio: pcm_s24le ([1][0][0][0] / 0x0001), 48000 Hz, stereo, s32 (24 bit), 2304 kb/s

mkvmerge stream-0.h264 stream-1.dts stream-2.dts stream-3.wav -o video.mkv

