#!/bin/sh
set -e

ROOTFS="${1}"

echo "Installing gdbserver" >&2

if [ ! -r gdbserver ]; then
	echo "WARNING: please compile gdb first" >&2
	exit 0
fi

cp -fv gdbserver "${ROOTFS}/usr/bin/"

