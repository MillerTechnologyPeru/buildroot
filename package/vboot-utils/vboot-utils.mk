################################################################################
#
# vboot-utils
#
################################################################################

VBOOT_UTILS_VERSION = 042312c6e7fce9dd106b329be0ecb51a8a347337
VBOOT_UTILS_SITE = https://chromium.googlesource.com/chromiumos/platform/vboot_reference
VBOOT_UTILS_SITE_METHOD = git
VBOOT_UTILS_LICENSE = BSD-3-Clause
VBOOT_UTILS_LICENSE_FILES = LICENSE

HOST_VBOOT_UTILS_DEPENDENCIES = host-openssl host-util-linux host-pkgconf

# vboot_reference contains code that goes into bootloaders,
# utilities intended for the target system, and a bunch of scripts
# for Chromium OS build system. Most of that does not make sense
# in a buildroot host-package.
#
# We only need futility for signing images, the keys, and cgpt for boot
# media partitioning.
#
# make target for futility is "futil".
#
# The value of ARCH is only relevant for crossystem (a target tool) and
# does not affect futil or cgpt in any way as long as it is one of the
# supported targets.

HOST_VBOOT_UTILS_MAKE_OPTS = USE_FLASHROM=0

define HOST_VBOOT_UTILS_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) $(HOST_VBOOT_UTILS_MAKE_OPTS) -C $(@D) \
		CC="$(HOSTCC)" \
		CPPFLAGS="$(HOST_CFLAGS) -D_LARGEFILE64_SOURCE -D_GNU_SOURCE" \
		LDFLAGS="$(HOST_LDFLAGS)" \
		ARCH=arm \
		futil cgpt
endef

define HOST_VBOOT_UTILS_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) $(HOST_VBOOT_UTILS_MAKE_OPTS) -C $(@D) \
		DESTDIR=$(HOST_DIR) \
		futil_install cgpt_install devkeys_install
endef

# cgpt for the target. Upstream's own note above - that vboot_reference holds
# "utilities intended for the target system" - is the reason: cgpt sets the
# ChromeOS slot attributes that decide which kernel a Chromebook boots, and
# doing that on the machine itself, rather than only when building an image
# for it, needs cgpt on the machine.
#
# futility is not built here, unlike the host package. It signs and inspects
# kernel images, which is work done where images are built, and it does not
# compile for a 32-bit target:
#
#   futility/cmd_vbutil_kernel.c:606:41: error: cast to pointer from integer
#     of different size [-Werror=int-to-pointer-cast]
#
# ARCH is normalised by the Makefile (aarch64 to arm64, i686 to x86, x86_64
# left alone), so Buildroot's own value can be handed over as it is.
VBOOT_UTILS_DEPENDENCIES = host-pkgconf openssl util-linux

VBOOT_UTILS_MAKE_OPTS = USE_FLASHROM=0

define VBOOT_UTILS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(VBOOT_UTILS_MAKE_OPTS) -C $(@D) \
		CC="$(TARGET_CC)" \
		CPPFLAGS="$(TARGET_CFLAGS) -D_LARGEFILE64_SOURCE -D_GNU_SOURCE" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		ARCH=$(call qstrip,$(BR2_ARCH)) \
		cgpt
endef

define VBOOT_UTILS_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(VBOOT_UTILS_MAKE_OPTS) -C $(@D) \
		DESTDIR=$(TARGET_DIR) \
		cgpt_install
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
