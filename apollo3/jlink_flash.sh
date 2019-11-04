#!/bin/bash

COMMAND_FILE_NAME=${0##*/}
COMMAND_FILE_NAME=${COMMAND_FILE_NAME%.*}.jlink

if [ $# -gt 0 ]; then
    BIN_FILE=$1
else
    BIN_FILE=$WORK_PATH/$SDK_NAME/boards/apollo3_evb/examples/binary_counter/gcc/bin/binary_counter.bin
fi

if [ ! -f $BIN_FILE ]; then
    echo "$BIN_FILE does not exist!!"
    exit 1;
fi

echo "//connect to device
device AMA3B1KK-KBR
si SWD
speed 1000
r
sleep 10

//mem32 0x0000C000 0x10
//mem32 0x0000E000 0x10

// Erase internal flash
w4 0x10000000 0x00000000 // instance number
w4 0x10000004 0x00000002 // number of main block pages to erase
w4 0x10000008 0x12344321 // PROGRAM key to pass to flash helper routine
w4 0x1000000C 0xFFFFFFFF // return code debugger sets this to -1 all RCs are >= 0
w4 0x10000010 0x00000006 // PageNumber of the first flash page to erase
setPC 0x08000065         // call the ROM helper function
g
sleep 50
mem32 0x1000000C 1

// Program second bootloader
loadbin $BIN_FILE 0x0000C000
sleep 50

// Reset without halting the device
rnh

// quit
qc" > $SCRIPT_PATH/$COMMAND_FILE_NAME

$JLINK_PATH/JLinkExe -CommanderScript $SCRIPT_PATH/$COMMAND_FILE_NAME

rm $SCRIPT_PATH/$COMMAND_FILE_NAME
