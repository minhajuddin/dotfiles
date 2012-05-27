#!/bin/bash
#script which is executed every hour
echo $(date +%H) end of hour >> $HOME/log/notification.log
