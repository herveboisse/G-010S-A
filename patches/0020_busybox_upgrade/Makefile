
BUSYBOX_RELEASE = 1.36.1
BUSYBOX_TAR = busybox-$(BUSYBOX_RELEASE).tar.bz2
BUSYBOX_URL = https://busybox.net/downloads/$(BUSYBOX_TAR)
BUSYBOX_DL = download/busybox-$(BUSYBOX_RELEASE)
BUSYBOX_LOCAL = local/busybox-$(BUSYBOX_RELEASE)
BUSYBOX_SRC = build/busybox-$(BUSYBOX_RELEASE)
BUSYBOX_PATCHES = $(addprefix https://github.com/openwrt/openwrt/raw/refs/heads/openwrt-24.10/package/utils/busybox/patches/, \
	120-lto-jobserver.patch \
	200-udhcpc_reduce_msgs.patch \
	201-udhcpc_changed_ifindex.patch \
	210-add_netmsg_util.patch \
	220-add_lock_util.patch \
	270-libbb_make_unicode_printable.patch \
	301-ip-link-fix-netlink-msg-size.patch \
	500-move-traceroute-applets-to-bin.patch \
	510-move-passwd-applet-to-bin.patch \
	520-loginutils-handle-crypt-failures.patch \
	530-nslookup-ensure-unique-transaction-IDs-for-the-DNS-queries.patch \
)


all: install


clean:
	rm -rf $(BUSYBOX_SRC)

$(BUSYBOX_DL):
	mkdir -p $@

$(BUSYBOX_SRC):
	mkdir -p $@

$(BUSYBOX_DL)/$(BUSYBOX_TAR): | $(BUSYBOX_DL)
	wget -O $@ $(BUSYBOX_URL)

$(BUSYBOX_DL)/.busybox_patches: | $(BUSYBOX_DL)
	rm -f $(BUSYBOX_DL)/*.patch
	cd $(BUSYBOX_DL) && wget $(BUSYBOX_PATCHES)
	@touch $@

$(BUSYBOX_SRC)/.busybox_unpacked: $(BUSYBOX_DL)/$(BUSYBOX_TAR) $(BUSYBOX_DL)/.busybox_patches | $(BUSYBOX_SRC)
	tar -C build -xf $<
	set -e; for p in $(BUSYBOX_DL)/*.patch; do patch -d $(BUSYBOX_SRC) -p1 < $$p; done
	@touch $@

$(BUSYBOX_SRC)/.config: $(BUSYBOX_LOCAL)/config $(BUSYBOX_SRC)/.busybox_unpacked
	cp $< $@

defconfig: $(BUSYBOX_SRC)/.busybox_unpacked
	$(MAKE) -C $(BUSYBOX_SRC) CROSS_COMPILE="$(CROSS_COMPILE)" defconfig

menuconfig: $(BUSYBOX_SRC)/.config
	$(MAKE) -C $(BUSYBOX_SRC) CROSS_COMPILE="$(CROSS_COMPILE)" menuconfig

install: $(BUSYBOX_SRC)/.config
	$(MAKE) -C $(BUSYBOX_SRC) CROSS_COMPILE="$(CROSS_COMPILE)" CC="$(CC)" AS="$(AS)" LD="$(LD)"
	rm -rf $(BUSYBOX_SRC)/_install install
	$(MAKE) -C $(BUSYBOX_SRC) CROSS_COMPILE="$(CROSS_COMPILE)" install
	cp -a $(BUSYBOX_SRC)/_install install


include ../../toolchain.mk

