#!/bin/sh

#
# Setup ENV
#
if [[ -z $WORK_PATH && -f envsetup.sh ]]; then
    source ./envsetup.sh
else
    echo ""
    echo " Need source \"envsetup.sh\" first!"
    echo ""
    exit 1
fi

CURRENT_PATH=$(cd $(dirname $0) && pwd)
echo "CURRENT_PATH = $CURRENT_PATH"
echo "WORK_PATH    = $WORK_PATH"
cd $WORK_PATH

#
# Setup SDK
#
if [ ! -d $SDK_NAME ]; then
    if [ -f $SDK_NAME.zip ]; then
	unzip $SDK_NAME.zip
	cd $SDK_NAME
	make clean
	git init .
	git add -A .
	git commit -m "git repository initial with $SDK_NAME.zip and make clean"
	cd -
    else
	echo ""
	echo " \"$SDK_NAME.tgz\" is not found!"
	echo " Which can be download manually from "
	echo " https://ambiqmicro.com/mcu/"
	echo " -> Apollo3 Blue"
	echo " -> Software"
	echo ""
	exit 1
    fi
fi

#
# Setup JLink
#
if [ ! -d $JLINK_NAME ]; then
    if [ -f JLink_Linux_V654a_x86_64.tgz ]; then
	tar xzvf $JLINK_NAME.tgz
    else
	echo ""
	echo " \"$JLINK_NAME.tgz\" is not found!"
	echo " Which can be download manually from https://www.segger.com/downloads/jlink/#J-LinkSoftwareAndDocumentationPack"
	echo ""
	exit 1
    fi
fi

#
# Check toolchains
#
if [ ! -x $TOOLCHAIN_PATH/arm-none-eabi-gcc ]; then
    	echo "$TOOLCHAIN_PATH/arm-none-eabi-gcc"
	echo ""
	echo " \"$TOOLCHAIN_NAME\" is not found!"
	echo " Which can be download manually from"
      	echo " https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads"
	echo ""
	exit 1
fi

#
# Generate setup script
#
echo "#!/bin/sh

export SCRIPT_PATH=$CURRENT_PATH
export PATH=\$PATH:\$SCRIPT_PATH
source \$SCRIPT_PATH/envsetup.sh
" > $WORK_PATH/setup.sh

chmod a+x $WORK_PATH/setup.sh

#
# Prepare codes
#
