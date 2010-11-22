#!/bin/bash
#
# makemp3.sh
#
# Encodes a wav-audio file into mp3 format, using lame.
#
# Features:
# - Normalize audio loudness to (89+1)dB
# - Automatic ID3-Tagging
#
# Requirements:
# For full ID3-Tag support, the script requires a special directory
# structure of the source (*.wav) audio files.:
#    .../Artist/Album/track - title.wav
#
# The encoded mp3 files are stored in the same tree structure,
# but on a different origin at $HOME/MP3/...
#
# Usage example:
#    makemp3.sh
#    This will encode all wav-files in all sub-directories recursively to mp3.
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
TOTALFILES=`find . -type f -iname "*.wav" -print | wc -l`
FILECOUNTER=1

find . -type f -iname "*.wav" -print0 | while read -d $'\0' file
do
  ORIGIN=`readlink -f "$file"`
  NUMTOKENS=`echo $ORIGIN | awk -F"/" '{print NF}'`
  if [ $NUMTOKENS -ge 4 ]
  then
    FILENAME=`echo $ORIGIN | awk -F"/" '{print $(NF)}' | awk -F".wav" '{print $1}'`
    FILEEXT="wav"
    FILEPATH=`echo $ORIGIN | awk -F"/" '{for (i=2;i<NF;i++) printf "%s/",$i}'`

    TRACKTITLE=$FILENAME
    TRACK=`echo $TRACKTITLE | awk -F" - " '{print $1}'`
    TITLE=`echo $TRACKTITLE | awk -F" - " '{print $2}'`
    ALBUM=`echo $ORIGIN | awk -F"/" '{print $(NF-1)}'`
    ARTIST=`echo $ORIGIN | awk -F"/" '{print $(NF-2)}'`

    SOURCEFILENAME="/$FILEPATH$FILENAME.$FILEEXT"
    TARGETPATH="$HOME/MP3/$ARTIST/$ALBUM"
    TARGETFILENAME="$TARGETPATH/$TRACK - $TITLE.mp3"

    message "Encoding ($FILECOUNTER of $TOTALFILES): '$file'"
    message "  Source-Filename: '$SOURCEFILENAME'"
    message "  Artist.........: '$ARTIST'"
    message "  Album..........: '$ALBUM'"
    message "  Track..........: '$TRACK'"
    message "  Title..........: '$TITLE'"
    message "  Target-Path....: '$TARGETPATH'"
    message "  Target-Filename: '$TARGETFILENAME'"
    message ""

    if [ ! -d "$TARGETPATH" ]
    then
      message "Creating target path '$TARGETPATH'"
      mkdir -p "$TARGETPATH"
      message ""
    fi

    # Main encoding
    lame --replaygain-accurate --clipdetect\
         -V 2 --vbr-new -q 0 --lowpass 19.7 -b96\
         --tt "$TITLE"\
         --ta "$ARTIST"\
         --tl "$ALBUM"\
         --tn "$TRACK"\
          "$SOURCEFILENAME" "$TARGETFILENAME" 2>&1 | tee /tmp/lameout.txt

    REPLAYGAIN=`cat /tmp/lameout.txt | grep "ReplayGain" | awk -F" |dB" '{print $2}'`
    SCALEFACTOR=`echo "tmp=e(((1$REPLAYGAIN)/20)*l(10)); tmp" | bc -l`
    message "  ReplayGain.....: $REPLAYGAIN"
    message "  Scale factor...: $SCALEFACTOR"

    # Adjusting normalization gain
    mp3gain -r -m 1 -k -s s "$TARGETFILENAME"

    # Cleanup
    rm -f /tmp/lameout.txt
    touch "$TARGETFILENAME" -r "$SOURCEFILENAME"
    sync
  else
    message "Incompatible directory structure: $ORIGIN" 
  fi
  
  let FILECOUNTER=$FILECOUNTER+1
done

