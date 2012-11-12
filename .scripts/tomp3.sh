#!/bin/bash

while read file
do
  mp3file="${file%%.*}.mp3"
  echo "converting '$file' to '$mp3file'"
  ffmpeg -i "$file" -vn -acodec libmp3lame -ac 2 -ab 160k -ar 48000 "$mp3file"
done
