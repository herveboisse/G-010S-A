
GDB_RELEASE = 7.6.1
GDB_TAR = gdb-$(GDB_RELEASE).tar.gz
GDB_URL = https://ftp.gnu.org/gnu/gdb/$(GDB_TAR)
GDB_DL = download/gdb-$(GDB_RELEASE)
GDB_SRC = build/gdb-$(GDB_RELEASE)
GDB_PATCHES = $(addprefix https://git.archive.openwrt.org/?p=14.07/openwrt.git\;a=blob_plain\;f=package/devel/gdb/patches/, \
	001-gdb-pr14523-mips-signal-number.patch \
)

GDB_CONF = \
	--target mips-openwrt-linux-uclibc \
	--disable-werror \
	--with-expat

GDBSERVER_CONF = \
	--host mips-openwrt-linux-uclibc \
	--disable-werror


# https://sourceware.org/gdb/wiki/BuildingCrossGDBandGDBserver

# there is mips-openwrt-linux-uclibc-gdb provided by the toolchain
# but it was built without XML support, which makes it unusable with gdbserver
# so we are building also gdb for the host
# see https://web.archive.org/web/20120817224525/http://comments.gmane.org/gmane.comp.gdb.devel/29306


all: gdb gdbserver


clean:
	rm -rf $(GDB_SRC)

$(GDB_DL):
	mkdir -p $@

$(GDB_SRC):
	mkdir -p $@

$(GDB_DL)/$(GDB_TAR): | $(GDB_DL)
	wget -O $@ $(GDB_URL)

$(GDB_DL)/.gdb_patches: | $(GDB_DL)
	rm -f $(GDB_DL)/*.patch
	cd $(GDB_DL) && wget --content-disposition $(GDB_PATCHES)
	@touch $@

$(GDB_SRC)/.gdb_unpacked: $(GDB_DL)/$(GDB_TAR) $(GDB_DL)/.gdb_patches | $(GDB_SRC)
	tar -C build -xf $<
	set -e; for p in $(GDB_DL)/*.patch; do patch -d $(GDB_SRC) -p1 < $$p; done
	sed -i '/^_GCC_AUTOCONF_VERSION_CHECK/d' $(GDB_SRC)/config/override.m4
	@touch $@

$(GDB_SRC)/.gdb_autoreconf: $(GDB_SRC)/.gdb_unpacked
	cd $(GDB_SRC) && autoreconf -if
	@touch $@

$(GDB_SRC)/.gdb_configured: $(GDB_SRC)/.gdb_autoreconf
	cd $(GDB_SRC) && unset AR AS CC CXX LD OBJCOPY RANLIB STRIP CROSS_COMPILE && ./configure $(GDB_CONF)
	@touch $@

gdb: $(GDB_SRC)/.gdb_configured
	$(MAKE) -C $(GDB_SRC)
	objcopy --strip-all $(GDB_SRC)/gdb/gdb gdb

$(GDB_SRC)/.gdbserver_autoreconf: $(GDB_SRC)/.gdb_unpacked
	cd $(GDB_SRC)/gdb/gdbserver && autoreconf -if
	@touch $@

$(GDB_SRC)/.gdbserver_configured: $(GDB_SRC)/.gdbserver_autoreconf
	cd $(GDB_SRC)/gdb/gdbserver && ./configure $(GDBSERVER_CONF)
	@touch $@

gdbserver: $(GDB_SRC)/.gdbserver_configured
	$(MAKE) -C $(GDB_SRC)/gdb/gdbserver
	$(OBJCOPY) --strip-all $(GDB_SRC)/gdb/gdbserver/gdbserver gdbserver


include ../../toolchain.mk

