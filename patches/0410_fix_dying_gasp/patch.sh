#!/bin/sh
set -e

ROOTFS="${1}"

# overwrite sfp_eeprom.sh with an older version (from firmware 3FE46398BFGA06)
# that does not have the dying gasp issue
cp -av "sfp_eeprom.sh" "${ROOTFS}/etc/init.d/"

# disable dying gasp in uci config
patch -p1 -d "${ROOTFS}" < disable-dying-gasp.diff

