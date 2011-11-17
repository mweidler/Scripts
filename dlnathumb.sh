#!/bin/bash
#
# Convert an DVD title image (from Lovefilm) into a square format, which is usable for
# MiniDLNA Thumbnail preview.
#
# November 2011, Marc Weidler
#
# Size: 429-6=423-416=7
#
# Usage: dlnathumb <imagefilename>
#set -x

ARGC=$#

if [ $ARGC -lt 1 ]
then
 echo "Usage: dlnathumb <imagefilename>"
 exit
fi

for (( I=1; $I <= $ARGC; I++ ))
do
   FILENAME=`echo "$1" | awk -F"." '{print $1}'`
   EXTENSION=`echo "$1" | awk -F"." '{print $2}'`

   convert "$1" -crop 300x416+0+6 -resize 416x416\> -size 416x416 xc:black +swap -gravity center -composite -quality 80 "_$FILENAME.jpg"
   mv "$1" "$1.old"
   mv "_$FILENAME.jpg" "$FILENAME.jpg"
done
