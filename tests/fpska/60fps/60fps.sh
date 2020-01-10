#!/bin/bash

vspipe --y4m 60fps.pvy - | ffmpeg -i pipe: -c:a copy -c:v libx264 -crf 20 -preset slow ../tmp/60fps.mp4 -v quiet -stats

if [ "$?" -ne "0" ] ; then
    echo "ошибка конвертации видео в формат 60 fps"
fi


