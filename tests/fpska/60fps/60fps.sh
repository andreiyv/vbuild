#!/bin/sh

vspipe --y4m 60fps.pvy - | ffmpeg -hide_banner -loglevel panic -i pipe: -c:a copy -c:v libx264 -crf 20 -preset slow ../tmp/60fps.mp4
