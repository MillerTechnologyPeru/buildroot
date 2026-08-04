################################################################################
#
# libxkbcommon
#
################################################################################

LIBXKBCOMMON_VERSION = 1.9.2
LIBXKBCOMMON_SITE = $(call github,xkbcommon,libxkbcommon,xkbcommon-$(LIBXKBCOMMON_VERSION))
LIBXKBCOMMON_LICENSE = MIT/X11
LIBXKBCOMMON_LICENSE_FILES = LICENSE
LIBXKBCOMMON_CPE_ID_VENDOR = xkbcommon
LIBXKBCOMMON_INSTALL_STAGING = YES
LIBXKBCOMMON_DEPENDENCIES = host-bison host-flex
LIBXKBCOMMON_CONF_OPTS = \
	-Denable-docs=false

# libxkbregistry, the keyboard layout catalogue half of the library. It is
# separate from libxkbcommon proper and parses the XML layout registry, so it
# is built only where libxml2 is - which is what kept it off by default here.
#
# wine wants it: configure.ac requires XKBREGISTRY_LIBS alongside
# wayland-client, wayland-scanner, xkbcommon and linux/input.h before it will
# build the Wayland driver, and wine.mk passes --with-wayland for any build
# with BR2_PACKAGE_WAYLAND, which turns the notice into a hard error -
#
#   checking for xkb_context_new in -lxkbcommon... yes
#   checking for wayland-egl.h... yes
#   configure: error: Wayland development files not found, the Wayland driver
#     won't be supported.
#   This is an error since --with-wayland was requested.
#
# with every other term of that test already satisfied. So wine plus wayland
# could not be built at all, on any architecture.
ifeq ($(BR2_PACKAGE_LIBXML2),y)
LIBXKBCOMMON_CONF_OPTS += -Denable-xkbregistry=true
LIBXKBCOMMON_DEPENDENCIES += libxml2
else
LIBXKBCOMMON_CONF_OPTS += -Denable-xkbregistry=false
endif

ifeq ($(BR2_PACKAGE_XORG7),y)
LIBXKBCOMMON_CONF_OPTS += -Denable-x11=true
LIBXKBCOMMON_DEPENDENCIES += libxcb
else
LIBXKBCOMMON_CONF_OPTS += -Denable-x11=false
endif

ifeq ($(BR2_PACKAGE_LIBXKBCOMMON_TOOLS),y)
LIBXKBCOMMON_CONF_OPTS += -Denable-tools=true
else
LIBXKBCOMMON_CONF_OPTS += -Denable-tools=false
endif

ifeq ($(BR2_PACKAGE_LIBXKBCOMMON_TOOLS)$(BR2_PACKAGE_WAYLAND),yy)
LIBXKBCOMMON_CONF_OPTS += -Denable-wayland=true
LIBXKBCOMMON_DEPENDENCIES += wayland wayland-protocols
else
LIBXKBCOMMON_CONF_OPTS += -Denable-wayland=false
endif

$(eval $(meson-package))
