#!/bin/bash

STREAMS=$(ffprobe -i test5.mkv 2>&1 | egrep Stream)

demuxer="ffmpeg -i test5.mkv -y -c copy -map " 

while IFS= read -r line; do

case $line in
     *"h264"*)
          demuxer+="0:0 stream-0.h264" 
          ;;
     *"aac"*)
          echo "aac"
          ;;
     *"Subtitle"*)
          echo "Subtitle"
          ;; 
     *)
          ;;
esac

done <<< "$STREAMS"

echo "$demuxer"

