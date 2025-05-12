#!/bin/sh
set -e

ROOTFS="${1}"

# small hack to allow running a script at end of boot from persistent storage (useful for debug)
patch -p1 -d "${ROOTFS}" < run-my-stuff.diff

