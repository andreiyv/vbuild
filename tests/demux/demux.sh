#!/bin/bash

STREAMS=$(ffprobe -i test5.mkv 2>&1 | egrep Stream)

while IFS= read -r line; do
    echo "$line"
done <<< "$STREAMS"

#case $STREAMS in
#     h264)
#          echo "Я тоже знаю Ubuntu! Эта система основана на Debian."
#          ;;
#     centos|rhel)
#          echo "Эй! Это мой любимый серверный дистрибутив!"
#          ;;
#     windows)
#          echo "Очень смешно..."
#          ;; 
#     *)
#          echo "Хмм, кажется я никогда не использовал этот дистрибутив."
#          ;;
#esac
