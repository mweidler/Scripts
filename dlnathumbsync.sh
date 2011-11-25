#!/bin/bash
#
# Sync movie and thumbnail image with the same timestamp.
# The movie timestamp is the reference.
#
# November 2011, Marc Weidler
#
# Usage: dlnathumbsync <imagefilename>
#set -x

ARGC=$#

if [ $ARGC -lt 1 ]
then
 echo "Usage: dlnathumbsync <moviefilename1> <moviefilename2> ..."
 exit
fi

for (( I=1; $I <= $ARGC; I++ ))
do
   FILENAME=`echo "$1" | awk -F"." '{print $1}'`
   EXTENSION=`echo "$1" | awk -F"." '{print $2}'`

   if [[ -e "$1" ]]
   then
      if [[ -e "$FILENAME.jpg" ]]
      then
        echo "Syncing '$FILENAME.jpg' with '$1'."
        touch "$FILENAME.jpg" -r "$1"
      fi
   fi

   shift
done

