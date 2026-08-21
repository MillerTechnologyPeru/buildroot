################################################################################
#
# librsvg
#
################################################################################

LIBRSVG_VERSION_MAJOR = 2.50
LIBRSVG_VERSION = $(LIBRSVG_VERSION_MAJOR).9
LIBRSVG_SITE = https://download.gnome.org/sources/librsvg/$(LIBRSVG_VERSION_MAJOR)
LIBRSVG_SOURCE = librsvg-$(LIBRSVG_VERSION).tar.xz
LIBRSVG_INSTALL_STAGING = YES
LIBRSVG_CONF_ENV = \
	LIBS=$(TARGET_NLS_LIBS) \
	RUST_TARGET=$(RUSTC_TARGET_NAME)
# The gdk-pixbuf SVG loader is what lets anything rasterise an SVG: GTK icon
# themes are SVG, and a desktop without it draws no icons at all.
#
# It also has to be built for the target/host answer to agree. gdk-pixbuf
# generates the target's loaders.cache from the loaders in HOST_DIR, and
# host-librsvg builds this loader, so the cache names
# /usr/lib/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader-svg.so whether or not
# the target has one. Disabling it here left the target with a cache promising
# a module that was not installed, and every SVG icon failing to load:
#
#   Gtk-WARNING **: Could not load a pixbuf from icon theme.
LIBRSVG_CONF_OPTS = --enable-pixbuf-loader --disable-tools
HOST_LIBRSVG_CONF_OPTS = --enable-introspection=no
LIBRSVG_DEPENDENCIES = cairo host-gdk-pixbuf gdk-pixbuf host-rustc libglib2 libxml2 pango \
	$(TARGET_NLS_DEPENDENCIES)
HOST_LIBRSVG_DEPENDENCIES = host-cairo host-gdk-pixbuf host-libglib2 host-libxml2 host-pango host-rustc
LIBRSVG_LICENSE = LGPL-2.1+
LIBRSVG_LICENSE_FILES = COPYING.LIB
LIBRSVG_CPE_ID_VENDOR = gnome
# We're patching gdk-pixbuf-loader/Makefile.am
LIBRSVG_AUTORECONF = YES

ifeq ($(BR2_PACKAGE_GOBJECT_INTROSPECTION),y)
LIBRSVG_CONF_OPTS += --enable-introspection
LIBRSVG_DEPENDENCIES += gobject-introspection
else
LIBRSVG_CONF_OPTS += --disable-introspection
endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))
