#!/bin/sh

export WORK_PATH=$HOME/work/codes/apollo3

export SDK_NAME=AmbiqSuite-R2.3.0
export JLINK_NAME=JLink_Linux_V654a_x86_64

export TOOLCHAIN_NAME=gcc-arm-none-eabi-8-2019-q3-update
export TOOLCHAIN_PATH=$HOME/toolchains/$TOOLCHAIN_NAME/bin

export TOOLCHAIN=$TOOLCHAIN_PATH/arm-none-eabi

export JLINK_PATH=$WORK_PATH/$JLINK_NAME
