
# assume toolchain is already setup and accessible in $PATH

CROSS_COMPILE := mips-openwrt-linux-uclibc-

# We use the *.bin directly : the wrapper is not needed and add rpath...
export AR = $(CROSS_COMPILE)ar
export AS = $(CROSS_COMPILE)as.bin
export CC = $(CROSS_COMPILE)gcc.bin
export CXX = $(CROSS_COMPILE)g++.bin
export LD = $(CROSS_COMPILE)ld.bin
export OBJCOPY = $(CROSS_COMPILE)objcopy
export RANLIB = $(CROSS_COMPILE)ranlib
export STRIP = $(CROSS_COMPILE)strip

# Prevent "warning: environment variable 'STAGING_DIR' not defined"
export STAGING_DIR

