
# yes, we are based on Debian Jessie, released in 2015
# because it is the closest Debian release to Lantiq SDK (OpenWRT 14.07)
FROM docker.io/debian/eol:jessie-slim

ARG repo_url="https://archive.openwrt.org/barrier_breaker/14.07/lantiq/xrx200/"
ARG toolchain="OpenWrt-Toolchain-lantiq-for-mips_34kc+dsp-gcc-4.8-linaro_uClibc-0.9.33.2"

# this Debian version is now archived, we need a special sources.list
COPY sources.list /etc/apt/

COPY gpgvnoexpkeysig /usr/bin/
RUN chmod +x /usr/bin/gpgvnoexpkeysig

COPY custom /etc/apt/apt.conf.d/

RUN apt-get -y update

RUN apt-get -y install \
	vim bash-completion \
	wget curl ca-certificates \
	bzip2 xz-utils \
	fakeroot \
	squashfs-tools bsdmainutils

# enable bash completion
RUN sed -i '/^# enable bash completion/I { :a n; s/^#//; t a; }' /etc/bash.bashrc

RUN apt-get -y install \
	build-essential \
	make \
	autoconf automake libtool \
	pkg-config \
	diffutils patch

# GDB dependencies
RUN apt-get -y install \
	libexpat1-dev ncurses-dev

RUN mkdir -pv /opt
WORKDIR /opt
ADD "${repo_url}${toolchain}.tar.bz2" .
RUN tar xf "${toolchain}.tar.bz2"
RUN rm -fv "${toolchain}".tar*

RUN echo "export PATH=\${PATH}:$(ls -d "/opt/${toolchain}/"toolchain-*/bin)" >> ~/.bashrc

