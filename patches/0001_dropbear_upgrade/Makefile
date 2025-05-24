DROPBEAR_RELEASE = 2024.86
DROPBEAR_TAR = dropbear-$(DROPBEAR_RELEASE).tar.bz2
DROPBEAR_URL = https://matt.ucc.asn.au/dropbear/releases/$(DROPBEAR_TAR)
DROPBEAR_DL = download/dropbear-$(DROPBEAR_RELEASE)
DROPBEAR_LOCAL = local/dropbear-$(DROPBEAR_RELEASE)
DROPBEAR_SRC = build/dropbear-$(DROPBEAR_RELEASE)
DROPBEAR_PATCHES = $(addprefix https://raw.githubusercontent.com/openwrt/openwrt/openwrt-24.10/package/network/services/dropbear/patches/, \
    100-pubkey_path.patch \
    110-change_user.patch \
    130-ssh_ignore_x_args.patch \
    140-disable_assert.patch \
    160-lto-jobserver.patch \
    600-allow-blank-root-password.patch \
    900-configure-hardening.patch \
    901-bundled-libs-cflags.patch \
    910-signkey-fix-use-of-rsa-sha2-256-pubkeys.patch \
)

DROPBEAR_CONF = \
    --host mips-openwrt-linux-uclibc \
    --disable-lastlog \
    --disable-utmpx \
    --disable-utmp \
    --disable-wtmp \
    --disable-wtmpx \
    --disable-loginfunc \
    --disable-pututline \
    --disable-pututxline \
    --disable-zlib \
    $()

# chacha20-poly1305 is more than 2x slower than aes-ctr for decryption on this HW.
# But it would be more than 2x faster for encryption.
DROPBEAR_DISABLED_FEATURES = \
    INETD_MODE \
    DROPBEAR_CLI_NETCAT \
    DROPBEAR_DSS \
    DO_MOTD \
    DROPBEAR_ECDSA \
    DROPBEAR_ECDH \
    DROPBEAR_CHACHA20POLY1305

all: dropbear

clean:
	rm -rf $(DROPBEAR_SRC)

$(DROPBEAR_DL):
	mkdir -p $@

$(DROPBEAR_SRC):
	mkdir -p $@

$(DROPBEAR_DL)/$(DROPBEAR_TAR): | $(DROPBEAR_DL)
	wget -O $@ $(DROPBEAR_URL)

$(DROPBEAR_DL)/.dropbear_patches: | $(DROPBEAR_DL)
	rm -f $(DROPBEAR_DL)/*.patch
	cd $(DROPBEAR_DL) && wget $(DROPBEAR_PATCHES)
	@touch $@

$(DROPBEAR_SRC)/.dropbear_unpacked: $(DROPBEAR_DL)/$(DROPBEAR_TAR) $(DROPBEAR_DL)/.dropbear_patches | $(DROPBEAR_SRC)
	tar -C build -xf $<
	set -e; for p in $(DROPBEAR_DL)/*.patch; do patch -d $(DROPBEAR_SRC) -p1 < $$p; done
	set -e; for p in $(DROPBEAR_LOCAL)/*.patch; do patch -d $(DROPBEAR_SRC) -p1 < $$p; done
	@touch $@

$(DROPBEAR_SRC)/.dropbear_autoreconf: $(DROPBEAR_SRC)/.dropbear_unpacked
	cd $(DROPBEAR_SRC) && autoreconf
	@touch $@

$(DROPBEAR_SRC)/.dropbear_configured: $(DROPBEAR_SRC)/.dropbear_autoreconf
	cd $(DROPBEAR_SRC) && ./configure $(DROPBEAR_CONF)
	printf "#define %s 0\n" $(DROPBEAR_DISABLED_FEATURES) > $(DROPBEAR_SRC)/localoptions.h
	@touch $@

dropbear: $(DROPBEAR_SRC)/.dropbear_configured
	$(MAKE) -C $(DROPBEAR_SRC) PROGRAMS="dropbear dbclient dropbearkey scp" MULTI=1 SCPPROGRESS=1
	$(OBJCOPY) --strip-all $(DROPBEAR_SRC)/dropbearmulti dropbear

include ../../toolchain.mk
