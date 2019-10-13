#!/bin/sh

if [ ! -f "../../workspace/lib/vapoursynth/libsvpflow1_vs64.so" ] && [ ! -f "../../workspace/lib/vapoursynth/libsvpflow2_vs64.so" ]; then
	mkdir /tmp/svp

	curl --silent https://www.svp-team.com/files/gpl/svpflow-4.3.0.168.zip --output /tmp/svp/plugin.zip

	unzip -o -d /tmp/svp /tmp/svp/plugin.zip

	cp /tmp/svp/svpflow-*/lib-linux/*.so ../../workspace/lib/vapoursynth/

	rm -rf /tmp/svp

else

	echo "SVP libraries were already downloaded"

fi

vspipe --y4m 60fps.pvy - | ffmpeg -i pipe: -c:a copy -c:v libx264 -crf 20 -preset slow 60fps.mp4
#vspipe --y4m 60fps.pvy - | ffplay -i pipe:
