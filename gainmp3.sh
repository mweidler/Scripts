#!/bin/bash
#
# gainmp3.sh
#
# Normalize the audio loudness of a mp3 file to (89+1)dB
#
# Usage example:
#    gainmp3.sh
#    This will normalize all mp3-files in all sub-directories recursively.
#
#
# Copyright (C) 2010 Marc Weidler (marc.weidler@web.de)
#
# THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.
# THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT
# WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
# THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.
# SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY
# SERVICING, REPAIR OR CORRECTION.
#
#set -x


###########################################################################
# message
#
# Print a colored message to stdout (currently blue color).
#
# Params:
# $1 Message to be printed on stdout
#
function message {
   echo -e "\033[1;34m$1\033[m"
}


###########################################################################
# Main loop
#
TOTALFILES=`find . -type f -iname "*.mp3" -print | wc -l`
FILECOUNTER=1

find . -type f -iname "*.mp3" -print0 | while read -d $'\0' file
do
  ORIGIN=`readlink -f "$file"`
  NUMTOKENS=`echo $ORIGIN | awk -F"/" '{print NF}'`
  if [ $NUMTOKENS -ge 4 ]
  then
    FILENAME=`echo $ORIGIN | awk -F"/" '{print $(NF)}' | awk -F".mp3" '{print $1}'`
    FILEEXT="mp3"
    FILEPATH=`echo $ORIGIN | awk -F"/" '{for (i=2;i<NF;i++) printf "%s/",$i}'`

    TRACKTITLE=$FILENAME
    TRACK=`echo $TRACKTITLE | awk -F" - " '{print $1}'`
    TITLE=`echo $TRACKTITLE | awk -F" - " '{print $2}'`
    ALBUM=`echo $ORIGIN | awk -F"/" '{print $(NF-1)}'`
    ARTIST=`echo $ORIGIN | awk -F"/" '{print $(NF-2)}'`

    SOURCEFILENAME="/$FILEPATH$FILENAME.$FILEEXT"

    message "Encoding ($FILECOUNTER of $TOTALFILES): '$file'"
    message "  Source-Filename: '$SOURCEFILENAME'"
    message "  Artist.........: '$ARTIST'"
    message "  Album..........: '$ALBUM'"
    message "  Track..........: '$TRACK'"
    message "  Title..........: '$TITLE'"

    # Adjusting normalization gain
    mp3gain -p -r -m 1 -k -s s "$SOURCEFILENAME" | tee /tmp/mp3gainout.txt
    APPLYGAIN=`tail -1 /tmp/mp3gainout.txt | grep "Applying" | awk -F"change of" '{print $2}' | awk -F" " '{print $1}'`
    message "  ApplyGain......: $APPLYGAIN"
    message ""

    # Cleanup
    rm -f /tmp/mp3gainout.txt
    sync
  else
    message "Incompatible directory structure: $ORIGIN" 
  fi
  
  let FILECOUNTER=$FILECOUNTER+1
done

