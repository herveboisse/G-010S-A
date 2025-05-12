#!/bin/sh
set -e

ROOTFS="${1}"

# disable dropbear idle timeout
sed -r -i '/\<IdleTimeout:uinteger:/ s/:[0-9]+/:0/' "${ROOTFS}/etc/init.d/dropbear"

