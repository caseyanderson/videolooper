#!/bin/sh

# get rid of the cursor
setterm -cursor off

#set path to folder containing videos
VIDEOPATH="/home/pi/videolooper/video"

# you can normally leave this alone
SERVICE="omxplayer"

# the loop
while true; do
        if ps ax | grep -v grep | grep $SERVICE > /dev/null
        then
        sleep 1;
else
        for entry in $VIDEOPATH/*
        do
                clear
                omxplayer -b --no-osd -o hdmi $entry > /dev/null
        done
fi
done

