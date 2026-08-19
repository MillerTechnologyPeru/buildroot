################################################################################
#
# libdisplay-info
#
################################################################################

LIBDISPLAY_INFO_VERSION = 0.4.0
LIBDISPLAY_INFO_SOURCE = libdisplay-info-$(LIBDISPLAY_INFO_VERSION).tar.xz
LIBDISPLAY_INFO_SITE = https://gitlab.freedesktop.org/emersion/libdisplay-info/-/releases/$(LIBDISPLAY_INFO_VERSION)/downloads
LIBDISPLAY_INFO_LICENSE = MIT
LIBDISPLAY_INFO_LICENSE_FILES = LICENSE
LIBDISPLAY_INFO_INSTALL_STAGING = YES
# host-hwdata as well: the pnp.ids lookup is dependency('hwdata',
# native: true) - a build-machine lookup - and the fallback is the build
# machine's /usr/share/hwdata/pnp.ids, which need not exist:
#
#   meson.build:24:11: ERROR: File /usr/share/hwdata/pnp.ids does not
#   exist.
#
# The target hwdata satisfies the run-time interest; the host one makes
# the build-time lookup deterministic.
LIBDISPLAY_INFO_DEPENDENCIES = hwdata host-hwdata

# workaround for static_assert on uclibc-ng < 1.0.42
LIBDISPLAY_INFO_CFLAGS += $(TARGET_CFLAGS) -Dstatic_assert=_Static_assert

$(eval $(meson-package))
