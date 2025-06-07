#!/bin/bash
set -e

warn () {
	echo "WARNING: ${*}" >&2
}

debug () {
	: #echo "DEBUG: ${*}" >&2
}


ROOTFS="${1}"

dbgdir="$(readlink -f "${ROOTFS}/..")"
dbgdir="${dbgdir##*/}.debug"


rm -rf "${dbgdir}"

while read f; do
	rf="${f:${#ROOTFS}}"

	if [ "${rf: -3}" = ".py" ]; then
		# python file
		debug "${rf} is a python file"

		# there is no python interpreter on the device
		rm -f "${f}"
		continue
	fi
	if [[ ${rf} =~ ^/(etc/(config|optic)/|usr/(cfg/|configs$)|lib/firmware/) ]]; then
		# files that should not be executable
		debug "${rf} should not be executable"
		chmod -x "${f}"
		continue
	fi

	hdr="$(hexdump -v -e '1/1 "%02x"' -n 20 "${f}")"

	if [ "${hdr:0:4}" = "2321" ]; then
		# "#!" -> interpreted file
		debug "${rf} is a script"
	elif [ "${rf: -3}" = ".sh" ]; then
		# shell script without shebang
		debug "${rf} is a shell script without shebang"
	elif [ "${hdr:0:8}" = "7f454c46" ]; then
		# "\x7FELF" -> ELF file
		# https://en.wikipedia.org/wiki/Executable_and_Linkable_Format#ELF_header

		stripopt=""
		if [ "${hdr:8:2}" != "01" ]; then
			warn "${rf} is an ELF file but not 32 bits"
		elif [ "${hdr:10:2}" != "02" ]; then
			warn "${rf} is an ELF file but not big endian"
		elif [ "${hdr:36:4}" != "0008" ]; then
			warn "${rf} is an ELF file but not MIPS machine"
		elif [ "${hdr:32:4}" = "0001" ]; then
			debug "${rf} is a relocatable ELF file"
			stripopt="--strip-unneeded"
			chmod -x "${f}"
		elif [ "${hdr:32:4}" = "0002" ]; then
			debug "${rf} is an executable ELF file"
			stripopt="-s"
		elif [ "${hdr:32:4}" = "0003" ]; then
			debug "${rf} is a shared object ELF file"
			stripopt="--strip-unneeded"
			chmod -x "${f}"
		else
			warn "${rf} is an unhandled type ELF file"
		fi

		if [ -n "${stripopt}" ]; then
			mkdir -p "${dbgdir}$(dirname "${rf}")"
			mips-openwrt-linux-objcopy --only-keep-debug "${f}" "${dbgdir}${rf}"
			mips-openwrt-linux-strip ${stripopt} "${f}"
		fi
	elif [ "${hdr:0:16}" = "213c617263683e0a" ]; then
		# "!<arch>\n" -> AR archive
		# https://en.wikipedia.org/wiki/Ar_(Unix)#File_header
		debug "${rf} is an AR archive"

		chmod -x "${f}"
		mkdir -p "${dbgdir}$(dirname "${rf}")"
		mv "${f}" "${dbgdir}${rf%.*}.a"
	else
		warn "${rf} is an unknown file"
	fi
done < <(find "${ROOTFS}" -type f \( -executable -o -name '*.so*' -o -name '*.ko' -o -name '*.py' \))

