#!/bin/sh

vspipe --y4m 60fps.pvy - | ffmpeg -i pipe: -c:a copy -c:v libx264 -crf 20 -preset slow ../tmp/60fps.mp4 -v quiet -stats
