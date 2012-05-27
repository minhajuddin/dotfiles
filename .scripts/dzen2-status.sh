#!/bin/zsh
#
# Usage: ./bar.sh [<desktop_number>]
#echo 'hello' | dzen2 -p -fg white -bg '#333333' -fn 'Bitstream Vera Sans Mono:size=9' -w '1280'
#
# Creates a clickable dzen bar that allows switching between desktops,
# optionally switching to the given desktop.
FG_FOCUS="#F0DFAF"
BG_FOCUS="#1E2320"
#Launch dzen2 and establish the pipe
if [[ ! -e /tmp/dzen2.pipe ]]
then
  socat PIPE:/tmp/dzen2.pipe EXEC:"dzen2 -p -ta l"&
fi
#Switch to the given desktop
if [[ ! -z $1 ]]
then
  wmctrl -s $1
fi
#Get all desktop names
DESKTOPS=(`wmctrl -d | cut -d\  -f14`)
#Create the dzen input
#The click action calls the script with argument the clicked desktop, and
#thus both swithes to this desktop and updates the dzen bar.
#
#The wm mappings to switch between desktop should call this script as well
line=""
for d in $DESKTOPS
do
  switchTo=`wmctrl -d | grep $d | cut -d\  -f1`
  if [[ -z "`wmctrl -d | grep $d | grep '*'`" ]]
  then
    line+="^ca(1,~/bar.sh $switchTo)$d^ca()"
  else
    line+="^ca(1,~/bar.sh $switchTo)^bg($BG_FOCUS)^fg($FG_FOCUS)$d^fg()^bg()^ca()"
  fi
done
#Forward the dzen input to dzen through the pipe
echo $line | socat - PIPE:/tmp/dzen2.pipe



##!/bin/zsh
##
## xmonad statusline, (c) 2007 by Robert Manea
##
 
## Configuration
#DATE_FORMAT='%A, %d.%m.%Y %H:%M:%S'
#TIME_ZONES=(Australia/Sydney America/Los_Angeles America/New_York)
#WEATHER_FORECASTER=/path/to/dzenWeather.pl
#DZEN_ICONPATH=
##MAILDIR=
 
## Main loop interval in seconds
#INTERVAL=1
 
## function calling intervals in seconds
#DATEIVAL=1
#GTIMEIVAL=60
#MAILIVAL=60
#CPUTEMPIVAL=1
#WEATHERIVAL=1800
 
## Functions
#fdate() {
    #date +$DATE_FORMAT
#}
 
#fgtime() {
    #local i
 
    #for i in $TIME_ZONES
        #{ print -n "${i:t}:" $(TZ=$i date +'%H:%M')' ' }
#}
 
##fcputemp() {
   ##print -n ${(@)$(</proc/acpi/thermal_zone/THRM/temperature)[2,3]}
##}
 
#fmail() {
    #local -A counts; local i
 
    #for i in "${MAILDIR:-${HOME}/Mail}"/**/new/*
        #{ (( counts[${i:h:h:t}]++ )) }
    #for i in ${(k)counts}
        #{ print -n $i: $counts[$i]' ' }
#}
 
#fweather() {
   #$WEATHER_FORECASTER
#}
 
 
## Main
 
## initialize data
#DATECOUNTER=$DATEIVAL;MAILCOUNTER=$MAILIVAL;GTIMECOUNTER=$GTIMEIVAL;CPUTEMPCOUNTER=$CPUTEMPIVAL;WEATHERCOUNTER=$WEATHERIVAL
 
#while true; do
   #if [ $DATECOUNTER -ge $DATEIVAL ]; then
     #PDATE=$(fdate)
     #DATECOUNTER=0
   #fi
 
   ##if [ $MAILCOUNTER -ge $MAILIVAL ]; then
     ##TMAIL=$(fmail)
       ##if [ $TMAIL ]; then
         ##PMAIL="^fg(khaki)^i(${DZENICONPATH}/mail.xpm)^p(3)${TMAIL}"
       ##else
         ##PMAIL="^fg(grey60)^i(${DZENICONPATH}/envelope.xbm)"
       ##fi
     ##MAILCOUNTER=0
   ##fi
 
   #if [ $GTIMECOUNTER -ge $GTIMEIVAL ]; then
     #PGTIME=$(fgtime)
     #GTIMECOUNTER=0
   #fi
 
   ##if [ $CPUTEMPCOUNTER -ge $CPUTEMPIVAL ]; then
     ##PCPUTEMP=$(fcputemp)
     ##CPUTEMPCOUNTER=0
   ##fi
 
   ##if [ $WEATHERCOUNTER -ge $WEATHERIVAL ]; then
     ##PWEATHER=$(fweather)
     ##WEATHERCOUNTER=0
   ##fi
 
   ## Arrange and print the status line
   ##print "$PWEATHER $PCPUTEMP $PGTIME $PMAIL ^fg(white)${PDATE}^fg()"
   #print "$PGTIME ^fg(white)${PDATE}^fg()"
 
   #DATECOUNTER=$((DATECOUNTER+1))
   ##MAILCOUNTER=$((MAILCOUNTER+1))
   #GTIMECOUNTER=$((GTIMECOUNTER+1))
   #CPUTEMPCOUNTER=$((CPUTEMPCOUNTER+1))
   ##WEATHERCOUNTER=$((WEATHERCOUNTER+1))
 
   #sleep $INTERVAL
#done





##!/bin/zsh
##
## Usage: ./bar.sh [<desktop_number>]
##echo 'hello' | dzen2 -p -fg white -bg '#333333' -fn 'Bitstream Vera Sans Mono:size=9' -w '1280'
##
## Creates a clickable dzen bar that allows switching between desktops,
## optionally switching to the given desktop.
#FG_FOCUS="#F0DFAF"
#BG_FOCUS="#1E2320"
##Launch dzen2 and establish the pipe
#if [[ ! -e /tmp/dzen2.pipe ]]
#then
  #socat PIPE:/tmp/dzen2.pipe EXEC:"dzen2 -p -ta l"&
#fi
##Switch to the given desktop
#if [[ ! -z $1 ]]
#then
  #wmctrl -s $1
#fi
##Get all desktop names
#DESKTOPS=(`wmctrl -d | cut -d\  -f14`)
##Create the dzen input
##The click action calls the script with argument the clicked desktop, and
##thus both swithes to this desktop and updates the dzen bar.
##
##The wm mappings to switch between desktop should call this script as well
#line=""
#for d in $DESKTOPS
#do
  #switchTo=`wmctrl -d | grep $d | cut -d\  -f1`
  #if [[ -z "`wmctrl -d | grep $d | grep '*'`" ]]
  #then
    #line+="^ca(1,~/bar.sh $switchTo)$d^ca()"
  #else
    #line+="^ca(1,~/bar.sh $switchTo)^bg($BG_FOCUS)^fg($FG_FOCUS)$d^fg()^bg()^ca()"
  #fi
#done
##Forward the dzen input to dzen through the pipe
#echo $line | socat - PIPE:/tmp/dzen2.pipe



###!/bin/zsh
###
### xmonad statusline, (c) 2007 by Robert Manea
###
 
### Configuration
##DATE_FORMAT='%A, %d.%m.%Y %H:%M:%S'
##TIME_ZONES=(Australia/Sydney America/Los_Angeles America/New_York)
##WEATHER_FORECASTER=/path/to/dzenWeather.pl
##DZEN_ICONPATH=
###MAILDIR=
 
### Main loop interval in seconds
##INTERVAL=1
 
### function calling intervals in seconds
##DATEIVAL=1
##GTIMEIVAL=60
##MAILIVAL=60
##CPUTEMPIVAL=1
##WEATHERIVAL=1800
 
### Functions
##fdate() {
    ##date +$DATE_FORMAT
##}
 
##fgtime() {
    ##local i
 
    ##for i in $TIME_ZONES
        ##{ print -n "${i:t}:" $(TZ=$i date +'%H:%M')' ' }
##}
 
###fcputemp() {
   ###print -n ${(@)$(</proc/acpi/thermal_zone/THRM/temperature)[2,3]}
###}
 
##fmail() {
    ##local -A counts; local i
 
    ##for i in "${MAILDIR:-${HOME}/Mail}"/**/new/*
        ##{ (( counts[${i:h:h:t}]++ )) }
    ##for i in ${(k)counts}
        ##{ print -n $i: $counts[$i]' ' }
##}
 
##fweather() {
   ##$WEATHER_FORECASTER
##}
 
 
### Main
 
### initialize data
##DATECOUNTER=$DATEIVAL;MAILCOUNTER=$MAILIVAL;GTIMECOUNTER=$GTIMEIVAL;CPUTEMPCOUNTER=$CPUTEMPIVAL;WEATHERCOUNTER=$WEATHERIVAL
 
##while true; do
   ##if [ $DATECOUNTER -ge $DATEIVAL ]; then
     ##PDATE=$(fdate)
     ##DATECOUNTER=0
   ##fi
 
   ###if [ $MAILCOUNTER -ge $MAILIVAL ]; then
     ###TMAIL=$(fmail)
       ###if [ $TMAIL ]; then
         ###PMAIL="^fg(khaki)^i(${DZENICONPATH}/mail.xpm)^p(3)${TMAIL}"
       ###else
         ###PMAIL="^fg(grey60)^i(${DZENICONPATH}/envelope.xbm)"
       ###fi
     ###MAILCOUNTER=0
   ###fi
 
   ##if [ $GTIMECOUNTER -ge $GTIMEIVAL ]; then
     ##PGTIME=$(fgtime)
     ##GTIMECOUNTER=0
   ##fi
 
   ###if [ $CPUTEMPCOUNTER -ge $CPUTEMPIVAL ]; then
     ###PCPUTEMP=$(fcputemp)
     ###CPUTEMPCOUNTER=0
   ###fi
 
   ###if [ $WEATHERCOUNTER -ge $WEATHERIVAL ]; then
     ###PWEATHER=$(fweather)
     ###WEATHERCOUNTER=0
   ###fi
 
   ### Arrange and print the status line
   ###print "$PWEATHER $PCPUTEMP $PGTIME $PMAIL ^fg(white)${PDATE}^fg()"
   ##print "$PGTIME ^fg(white)${PDATE}^fg()"
 
   ##DATECOUNTER=$((DATECOUNTER+1))
   ###MAILCOUNTER=$((MAILCOUNTER+1))
   ##GTIMECOUNTER=$((GTIMECOUNTER+1))
   ##CPUTEMPCOUNTER=$((CPUTEMPCOUNTER+1))
   ###WEATHERCOUNTER=$((WEATHERCOUNTER+1))
 
   ##sleep $INTERVAL
##done


