#!/usr/local/bin/bash
# ffmpeg -i "$1" -acodec libvorbis -q:a 5 "$1.ogg"
ffmpeg -i "$1" audio.wav
oggenc audio.wav -o aoudio.ogg
