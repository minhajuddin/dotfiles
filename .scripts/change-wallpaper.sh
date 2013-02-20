#!/bin/bash
# Author: Khaja Minhajuddin (http://minhajuddin.com) 

# Changes your current wallpaper
# Needs xloadimage

__STOP_FILE=/tmp/.stop-wallpaper

case $1 in
  stop) touch $__STOP_FILE
    exit
    ;;
  start) rm $__STOP_FILE
    exit
    ;;
esac

if [ -e  $__STOP_FILE ] 
then
  exit 
fi

# Extra:
# crontab entry to change your wallaper every minute
# * * * * * DISPLAY=:1 /home/minhajuddin/.scripts/change-wallpaper.sh
# You can get your display value by running 
# $ env | grep DISPLAY`

# directory containing all wallpapers
__WALLPAPERS_DIR=~/Dropbox/wallpapers/active
# file to store the current wallpaper number
__WALLPAPERS_INDEX_FILE=/tmp/.wallpaper
# if the computer has just started this file wouldn't be present
# in this case, create a file with a index starting at 0
# if you want the index to persist change the path above to
# a persistent path like ~/.wallpaper
if [ ! -e  $__WALLPAPERS_INDEX_FILE ] 
then
  echo '0' > $__WALLPAPERS_INDEX_FILE
fi

__NUM_WALLPAPERS=$(ls $__WALLPAPERS_DIR|wc -l )
# get the current index
__WALLPAPERS_INDEX=$(cat $__WALLPAPERS_INDEX_FILE)
# make sure the index doesn't get greater than the number of wallapers
__WALLPAPERS_INDEX=$(( $__WALLPAPERS_INDEX % $__NUM_WALLPAPERS + 1 ))
# store the next index in the file
echo  $__WALLPAPERS_INDEX > $__WALLPAPERS_INDEX_FILE
# change the wallpaper
xloadimage -onroot "$__WALLPAPERS_DIR/$(ls $__WALLPAPERS_DIR | sed -n "$__WALLPAPERS_INDEX p" )" &> /dev/null
