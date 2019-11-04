#!/bin/bash

if [ ! -x $JLINK_PATH/JLinkSWOViewerCLExe ]; then 
    echo ""
    echo " $JLINK_PATH/JLinkSWOViewerCLExe cannot be found!"
    echo ""
    exit 1
fi

if [ $# -gt 0 ]; then
    echo "$JLINK_PATH/JLinkSWOViewerCLExe -device AMA3B1KK-KBR -swofreq 1000000 -outputfile $1"
    $JLINK_PATH/JLinkSWOViewerCLExe -device AMA3B1KK-KBR -swofreq 1000000 -outputfile $1
else
    echo "$JLINK_PATH/JLinkSWOViewerCLExe -device AMA3B1KK-KBR -swofreq 1000000"
    $JLINK_PATH/JLinkSWOViewerCLExe -device AMA3B1KK-KBR -swofreq 1000000
fi
