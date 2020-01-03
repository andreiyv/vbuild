#!/bin/bash

STREAMS=$(ffprobe -i test5.mkv 2>&1 | egrep Stream)

demuxer="ffmpeg -hide_banner -loglevel panic -i test5.mkv -y " 

while IFS= read -r line; do

	map=$(echo $line | egrep -o 'Stream #[0-9]+:[0-9]+' | sed -r 's/Stream \#//')
	snumber=$(echo $map | sed -r 's/[0-9]\://')

case $line in
     *"h264"*)
          demuxer+="-map $map -c copy stream-$snumber.h264 "
          ;;
     *"aac"*)
          demuxer+="-map $map -c copy stream-$snumber.aac "
          ;;
     *"ac3"*)
          demuxer+="-map $map -c copy stream-$snumber.ac3 "
          ;;
     *"wma"*)
          demuxer+="-map $map -c copy stream-$snumber.wma "
          ;;
     *"mp3"*)
          demuxer+="-map $map -c copy stream-$snumber.mp3 "
          ;;
     *"dts"*)
          demuxer+="-map $map -c copy stream-$snumber.dts "
          ;;
     *"pcm"*)
          demuxer+="-map $map -c pcm_s24le stream-$snumber.wav "
          ;;
     *"Subtitle"*)
          demuxer+="-map $map stream-$snumber.srt "
          ;; 
     *)
          ;;
esac

done <<< "$STREAMS"

#echo "$demuxer"

$demuxer

