#!/bin/bash
#
# snapback.sh
#
# Backup script with rsync and hard links.
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


HISTORIES=45
ENUM=$(seq $((HISTORIES-1)) -1 1)

###########################################################################
# syncDirectory
#
# Copy data from source to backup using rsync
#
# Parameter: $1 Kompletter Pfadname Quell-Directory
#            $2 Kompletter Pfadname Backup-Directory
#
function syncDirectory {
    echo Sync $1 to backup $2
    rsync -a --delete --exclude=lost+found --exclude=.dbus* $1 $2
    touch $2
    echo Sync $1 to $2 done
}


###########################################################################
# shiftHistory
#
# Das aelteste Backup loeschen und alle anderen Snapshots
# eine Nummer nach oben verschieben.
#
# Parameter: $1 Kompletter Pfadname Backup-Directory
#
function shiftHistory {
    if [ -d $1/backup.$HISTORIES ]
    then
        echo Removing $1/backup.$HISTORIES
        rm -rf $1/backup.$HISTORIES
    else
        echo $1/backup.$HISTORIES does not exist, ignoring.
    fi

    for i in $ENUM
    do
        if [ -d $1/backup.$i ]
        then
            # Datum sichern
            touch /tmp/timestamp -r $1/backup.$i
            echo Renaming $1/backup.$i to $1/backup.$((i+1))
            mv $1/backup.$i $1/backup.$((i+1))
            # Datum zurueckspielen
            touch $1/backup.$((i+1)) -r /tmp/timestamp
            rm /tmp/timestamp
        else
            echo Ignoring backup history $i
        fi
    done
}

###########################################################################
# makeHardcopy
#
# Copy mittels Hardlinks erstellen.
#
# Parameter: $1 Kompletter Pfadname Backup-Directory
#
function makeHardcopy {
    if [ -d $1/backup.0 ]
    then
        # Snapshot von Level-0 per hardlink-Kopie nach Level-1 kopieren
        echo Hardlink copy $1/backup.0 $1/backup.1
        cp -al $1/backup.0 $1/backup.1
    fi
}


###########################################################################
# backup.sh <target-path>
#
# Parameter: $1 Kompletter Pfadname Backup-Directory
#
if [ $# -eq 1 ]
then
    BACKUP_PATH=${1%%/}

    if [ -d $BACKUP_PATH ]
    then
        shiftHistory $BACKUP_PATH
        makeHardcopy $BACKUP_PATH

        # Original-Daten mit Backup synchronisieren
        syncDirectory /media/share     $BACKUP_PATH/backup.0/
        syncDirectory /home/mweidler   $BACKUP_PATH/backup.0/

        echo Timestamp backup
        touch $BACKUP_PATH

        # Schreibe alle Daten auf Festplatte
        echo Sync, please be patient...
        sync
        sleep 5
        echo Done.
    else
        echo $BACKUP_PATH does not exists, exiting.
    fi
else
   echo "Usage: backup <target-path>"
   echo "       e.g. backup /media/Freecom"
fi

