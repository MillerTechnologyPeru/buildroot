################################################################################
#
# xlib_libxcvt
#
################################################################################

XLIB_LIBXCVT_VERSION = 0.1.3
XLIB_LIBXCVT_SOURCE = libxcvt-$(XLIB_LIBXCVT_VERSION).tar.xz
XLIB_LIBXCVT_SITE = https://xorg.freedesktop.org/archive/individual/lib
XLIB_LIBXCVT_LICENSE = MIT
XLIB_LIBXCVT_LICENSE_FILES = COPYING
XLIB_LIBXCVT_INSTALL_STAGING = YES

$(eval $(meson-package))
# The host variant is for the cvt program: mutter's native backend runs it
# at build time, through gen-default-modes.py, to compute the default
# display modes it compiles in.
$(eval $(host-meson-package))
