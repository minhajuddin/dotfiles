#!/bin/bash
#Author: Khaja Minhajuddin
#Wait for go files to be modified and then execute them
#Dependency: inotify-tools
#Install on ubuntu using: apt-get install inotify-tools


#the command before the pipe is a blocking command, i.e. it doesn't end
inotifywait -mrq --format '%f' -e close_write $1 | while read file
do
  #here we filter any changes to files other than go files
  if (echo $file | grep -E '^.*\.go$')
  then
    #once we know that a go file has been written to we run it
    clear
    echo "executing 'go run $file'"
    go run $file 
  fi
done
