#!/bin/sh
set -e

IMAGE="$1"

if [ -z "$IMAGE" -o ! -e "$IMAGE" ]; then
	echo "Usage : $0 image"
	exit 1
fi


DIR="${IMAGE%.*}"
ROOTFS="$DIR/squashfs-root"
ROOTFS_ABS="$PWD/$ROOTFS"

printf "\nCreating new squashfs image\n"
mksquashfs "$ROOTFS" patched.squashfs -noappend -comp xz -b 262144

OUT="${IMAGE%.*}_patched.bin"
cat "$DIR/uImage" patched.squashfs > "$OUT"
sz="$(stat -c '%s' "${OUT}")"
sz=$(( (6 << 20) - sz ))
if [ ${sz} -lt 0 ]; then
	echo "ERROR: image is too big of ${sz#-} bytes" >&2
	rm "${OUT}"
	exit 1
else
	echo "INFO: adding ${sz} bytes of padding" >&2
fi
dd if=/dev/null of="$OUT" bs=1 seek=6291456
printf "\n%s created successfully\n" "$OUT"

rm patched.squashfs

