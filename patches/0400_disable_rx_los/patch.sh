#!/bin/sh
set -e

ROOTFS="${1}"

# disable RX_LOS to be able to access SSH even without fiber plugged-in
# NOTE: the modification is not perfect, the RX_LOS signal will still
# be enabled some amount of time while the OS boots
patch -p1 -d "${ROOTFS}" < disable-rx-los.diff

