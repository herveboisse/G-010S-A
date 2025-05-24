#!/bin/sh
set -e

ROOTFS="${1}"

echo "Updating dropbear" >&2
if [ ! -r dropbear ]; then
	echo "WARNING: please compile dropbear first" >&2
	exit 0
fi

cp -fv dropbear "${ROOTFS}/usr/sbin/"

