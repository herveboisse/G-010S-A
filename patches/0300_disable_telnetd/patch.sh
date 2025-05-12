#!/bin/sh
set -e

ROOTFS="${1}"

# disable telnetd service autostart
rm -fv "${ROOTFS}"/etc/rc.d/*telnet

