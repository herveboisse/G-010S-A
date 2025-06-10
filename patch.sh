#!/bin/sh

set -e

IMAGE="$1"

if [ -z "$IMAGE" ] || [ ! -e "$IMAGE" ]
then
    echo "Usage : $0 image"
    exit 1
fi

if [ "$(id -u)" -ne 0 ]
then
    echo "Not running as root, using fakeroot"
    exec fakeroot "$0" "$IMAGE"
fi

./extract.sh "$IMAGE"

DIR="${IMAGE%.*}"
ROOTFS="$DIR/squashfs-root"
ROOTFS_ABS="$PWD/$ROOTFS"

printf "\nPatching rootfs ...\n"
for PATCH_DIR in patches/*
do
    [ -x "${PATCH_DIR}/patch.sh" ] || continue
    echo " - $PATCH_DIR :"
    cd "$PATCH_DIR" && { ./patch.sh "$ROOTFS_ABS"; cd ../..; }
done

./repack.sh "$IMAGE"
