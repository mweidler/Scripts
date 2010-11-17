#!/bin/bash
#
# install.sh
#
# Installs makemp3.sh either in the $HOME/bin directory or sets a symbolic
# link from the $HOME/bin to the script in the current directory.
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

clear
echo makemp3 script installation

if [ -e "$HOME/bin/makemp3.sh" ]
then
   echo "WARNING: $HOME/bin/makemp3.sh already exists, please be careful."
   echo ""
fi

echo What do you want to do?
echo Please select one of the following choices:
PS3='Your choice? '
select term in "Copy script to $HOME/bin" "Link script from $HOME/bin"
do
  case $REPLY in
     1 ) CHOICE=1 ;;
     2 ) CHOICE=2 ;;
     * ) ;;
  esac

  if [ -n "$term" ]
  then
    break
  else
    echo Sorry, invalid choice. Please try again.
  fi
done

echo $term

if [ $CHOICE -eq 1 ]
then
  cp makemp3.sh $HOME/bin
fi

if [ $CHOICE -eq 2 ]
then
  rm -f $HOME/bin/makemp3.sh
  ln -s `pwd`/makemp3.sh $HOME/bin/makemp3.sh
fi
