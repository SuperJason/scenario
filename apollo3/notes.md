* Host OS
  * Ubuntu 16.04.6 LTS (Xenial Xerus)

* Hareware
  * ambiq micro AMA3B1KK-KBR EVB v1.0

* SDK
  * AmbiqSuite-R2.3.0
      https://ambiqmicro.com/mcu/
      -> Apollo3 Blue
      -> Software

* Docs
  * Quick Start Guide, https://ambiqmicro.com/static/mcu/files/Apollo3_EVB_Quick_Start_Guide_r1p0.pdf
  * Datasheet, https://www.ambiqmicro.com/static/mcu/files/Apollo3_Blue_MCU_Data_Sheet_v0_10_0.pdf
  * Schamtic, https://ambiqmicro.com/static/mcu/files/AMA3B1KK-KBR_EVB_schematic_v1_6_for_EVB_v1_0.pdf

* Tools
  * Jlink, V6.54a, https://www.segger.com/downloads/jlink/#J-LinkSoftwareAndDocumentationPack
  * Toolchain, Version 8-2019-q3-update Linux 64-bit
      https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads

* Scenario Setup
  * scenario_setup.sh

* Make
  * cd AmbiqSuite-R2.3.0
  * . ../setup.sh
  * make -j8 bsp
  * make -C boards/apollo3_evb/examples/binary_counter/gcc/
  * make -C boards/apollo3_evb/examples/ble_freertos_amdtpc/

* Flash Download
  * cd AmbiqSuite-R2.3.0
  * . ../setup.sh
  * jlink_flash.sh boards/apollo3_evb/examples/binary_counter/gcc/bin/binary_counter.bin

* Debug
  * GDB: jlink_gdb.sh boards/apollo3_evb/examples/binary_counter/gcc/bin/binary_counter.bin
  * SWO logs: jlink_swoview.sh
