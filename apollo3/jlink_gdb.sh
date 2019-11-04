#!/bin/bash

GDB=$TOOLCHAIN-gdb

if [[ $# -gt 0 && $1 != "swo" ]]; then
    ELF=$1
else
    ELF=$WORK_PATH/$SDK_NAME/boards/apollo3_evb/examples/binary_counter/gcc/bin/binary_counter.axf
fi

if [ ! -x $GDB ]; then 
    echo ""
    echo " $GDB cannot be found!"
    echo ""
    exit 1
fi


if [[ $1 == "swo" || $# -gt 1 ]]; then
    # With SWO log window
    gnome-terminal --geometry=116x16+1380+32 -e "$JLINK_PATH/JLinkGDBServerCLExe -device AMA3B1KK-KBR -if SWD"
    gnome-terminal --geometry=116x16+1380+340 -e "$JLINK_PATH/JLinkSWOViewerCLExe -device AMA3B1KK-KBR -swofreq 1000000"
    gnome-terminal --geometry=116x72+1380+650 -e "$GDB -ex \"target remote localhost:2331\" -ex \"monitor reset\" $ELF"
else
    gnome-terminal --geometry=116x26+1380+32 -e "$JLINK_PATH/JLinkGDBServerCLExe -device AMA3B1KK-KBR -if SWD"
    gnome-terminal --geometry=116x80+1380+504 -e "$GDB -ex \"target remote localhost:2331\" -ex \"monitor reset\" $ELF"
fi
