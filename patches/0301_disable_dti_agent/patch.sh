#!/bin/sh
set -e

ROOTFS="${1}"

# disable gpon dti agent service autostart
rm -fv "${ROOTFS}"/etc/rc.d/*load_dti_agent*

