#!/bin/sh

set -e

ROOTFS=$1

echo "Updating dropbear to 2020.81"
cp -f dropbear "$ROOTFS/usr/sbin/dropbear"
