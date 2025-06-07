#!/bin/bash
set -e

err () {
	echo "ERROR: ${*}" >&2
}

warn () {
	echo "WARNING: ${*}" >&2
}

debug () {
	: #echo "DEBUG: ${*}" >&2
}


ROOTFS="${1}"

echo "Updating busybox" >&2
if [ ! -d install ]; then
	warn "please compile busybox first"
	exit 0
fi

# verify that new busybox install will not collide with existing files
conflicts=0
while read f; do
	f="${f#install}"

	bf="$(basename "${f}")"
	bf="$(ls "${ROOTFS}/"{,usr/}{,s}bin"/${bf}" 2>/dev/null)" || true

	if [ -z "${bf}" ]; then
		debug "${f} is not present"
	elif [ "${bf}" -ef "${ROOTFS}/bin/busybox" ]; then
		debug "${f} exists as ${bf:${#ROOTFS}} and is busybox"
	else
		err "${f} already exists as ${bf:${#ROOTFS}} and is not busybox"
		conflicts=$(( conflicts + 1 ))
	fi
done < <(find "install" -type l)

# verify that new busybox install will not remove existing applets
missing=0
while read f; do
	f="${f:${#ROOTFS}}"

	nf="$(basename "${f}")"
	nf="$(ls install/{,usr/}{,s}bin"/${nf}" 2>/dev/null)" || true

	if [ -z "${nf}" ]; then
		err "${f} will not be present"
		missing=$(( missing + 1 ))
	else
		debug "${f} present as ${nf#install}"
	fi
done < <(find -L "${ROOTFS}" -xtype l -samefile "${ROOTFS}/bin/busybox")

if [ ${conflicts} -gt 0 ]; then
	err "found ${conflicts} filesystem conflict(s)"
fi
if [ ${missing} -gt 0 ]; then
	err "found ${missing} missing applet(s)"
fi
if [ ${conflicts} -gt 0 -o ${missing} -gt 0 ]; then
	err "problems detected, aborting"
	exit 1
fi

# remove already existing busybox install
find -L "${ROOTFS}" -xtype l -samefile "${ROOTFS}/bin/busybox" -delete
rm -f "${ROOTFS}/bin/busybox"

# copy new busybox install
cp -a install/* "${ROOTFS}/"

