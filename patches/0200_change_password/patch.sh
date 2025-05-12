#!/bin/sh
set -e

ROOTFS="${1}"

if [ ! -r password ]; then
	echo "WARNING: please create a file named \"password\" with the actual password" >&2
	exit 0
fi

pw="$(head -n 1 password)"
pw="$(openssl passwd -1 "${pw}")"
sed -r -i "/^ONTUSER:/ s@:[^:]+:@:${pw}:@" "${ROOTFS}/etc/shadow"

# NOTE: web interface credentials can be changed with "ritool" directly on the device,
# with variables "MgntUserName" and "MgntUserPassword"

