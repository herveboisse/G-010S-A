#!/bin/sh
set -e

ROOTFS="${1}"

# remove useless files
find "${ROOTFS}" -name 'dummp.file' -print -delete
find "${ROOTFS}" -name 'magic' -print -delete

