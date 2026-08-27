################################################################################
#
# libheif
#
################################################################################

LIBHEIF_VERSION = 1.23.1
LIBHEIF_SITE = https://github.com/strukturag/libheif/releases/download/v$(LIBHEIF_VERSION)
LIBHEIF_LICENSE = LGPL-3.0+
LIBHEIF_LICENSE_FILES = COPYING
LIBHEIF_CPE_ID_VENDOR = struktur
LIBHEIF_INSTALL_STAGING = YES
LIBHEIF_CONF_OPTS = \
	-DENABLE_PLUGIN_LOADING=OFF \
	-DWITH_AOM_DECODER=OFF \
	-DWITH_AOM_ENCODER=OFF \
	-DWITH_DEFLATE_HEADER_COMPRESSION=OFF \
	-DWITH_EXAMPLES=OFF \
	-DWITH_LIBSHARPYUV=OFF \
	-DWITH_RAV1E=OFF \
	-DWITH_REDUCED_VISIBILITY=ON \
	-DWITH_SvtEnc=OFF

ifeq ($(BR2_PACKAGE_DAV1D),y)
LIBHEIF_CONF_OPTS += -DWITH_DAV1D=ON
LIBHEIF_DEPENDENCIES += dav1d
else
LIBHEIF_CONF_OPTS += -DWITH_DAV1D=OFF
endif

ifeq ($(BR2_PACKAGE_FFMPEG),y)
LIBHEIF_CONF_OPTS += -DWITH_FFMPEG_DECODER=ON
LIBHEIF_DEPENDENCIES += ffmpeg
else
LIBHEIF_CONF_OPTS += -DWITH_FFMPEG_DECODER=OFF
endif

ifeq ($(BR2_PACKAGE_KVAZAAR),y)
LIBHEIF_CONF_OPTS += -DWITH_KVAZAAR=ON
LIBHEIF_DEPENDENCIES += kvazaar
else
LIBHEIF_CONF_OPTS += -DWITH_KVAZAAR=OFF
endif

ifeq ($(BR2_PACKAGE_LIBDE265),y)
LIBHEIF_CONF_OPTS += -DWITH_LIBDE265=ON
LIBHEIF_DEPENDENCIES += libde265
else
LIBHEIF_CONF_OPTS += -DWITH_LIBDE265=OFF
endif

ifeq ($(BR2_PACKAGE_JPEG),y)
LIBHEIF_CONF_OPTS += -DWITH_JPEG_DECODER=ON -DWITH_JPEG_ENCODER=ON
LIBHEIF_DEPENDENCIES += jpeg
else
LIBHEIF_CONF_OPTS += -DWITH_JPEG_DECODER=OFF -DWITH_JPEG_ENCODER=OFF
endif

ifeq ($(BR2_PACKAGE_OPENJPEG),y)
LIBHEIF_CONF_OPTS += -DWITH_OpenJPEG_DECODER=ON -DWITH_OpenJPEG_ENCODER=ON
LIBHEIF_DEPENDENCIES += openjpeg
else
LIBHEIF_CONF_OPTS += -DWITH_OpenJPEG_DECODER=OFF -DWITH_OpenJPEG_ENCODER=OFF
endif

ifeq ($(BR2_PACKAGE_X265),y)
LIBHEIF_CONF_OPTS += -DWITH_X265=ON
LIBHEIF_DEPENDENCIES += x265
else
LIBHEIF_CONF_OPTS += -DWITH_X265=OFF
endif

ifeq ($(BR2_TOOLCHAIN_HAS_GCC_BUG_64735),y)
LIBHEIF_CONF_OPTS += -DENABLE_PARALLEL_TILE_DECODING=OFF
else
LIBHEIF_CONF_OPTS += -DENABLE_PARALLEL_TILE_DECODING=ON
endif

# The gdk-pixbuf loader, which is what makes a HEIC file visible to GTK
# rather than only to programs that link libheif themselves - nautilus
# thumbnails, the image viewer, anything going through GdkPixbuf.
#
# Where it installs is decided by pkg-config:
#
#   pkg-config gdk-pixbuf-2.0 --variable gdk_pixbuf_moduledir \
#             --define-variable=prefix=$(CMAKE_INSTALL_PREFIX)
#
# gdk_pixbuf_moduledir derives from libdir, which pkgconf sysroot-prefixes,
# so without that --define-variable it would answer with an absolute path
# into the staging tree and the install would reproduce the whole build path
# under DESTDIR - the failure librsvg carries a comment about. libheif
# passes it already, so the answer is /usr/lib/gdk-pixbuf-2.0/2.10.0/loaders
# for the target and $(HOST_DIR)/lib/... for the host, both correct.
ifeq ($(BR2_PACKAGE_GDK_PIXBUF),y)
LIBHEIF_CONF_OPTS += -DWITH_GDK_PIXBUF=ON
LIBHEIF_DEPENDENCIES += gdk-pixbuf
else
LIBHEIF_CONF_OPTS += -DWITH_GDK_PIXBUF=OFF
endif

# The host build exists only for that loader, and only so it can be seen.
# gdk-pixbuf builds the target's loaders.cache by running
# gdk-pixbuf-query-loaders over the loaders in HOST_DIR - it cannot dlopen a
# target module to ask what it handles - so a loader with no host counterpart
# is installed on the target and named in no cache, which is a file that
# never loads. Hence a host libheif whose only configured feature is the
# loader: no codecs, nothing else built, since what is wanted from it is the
# module's declared mime types and nothing more.
HOST_LIBHEIF_CONF_OPTS = \
	-DENABLE_PLUGIN_LOADING=OFF \
	-DWITH_AOM_DECODER=OFF \
	-DWITH_AOM_ENCODER=OFF \
	-DWITH_DAV1D=OFF \
	-DWITH_DEFLATE_HEADER_COMPRESSION=OFF \
	-DWITH_EXAMPLES=OFF \
	-DWITH_FFMPEG_DECODER=OFF \
	-DWITH_GDK_PIXBUF=ON \
	-DWITH_JPEG_DECODER=OFF \
	-DWITH_JPEG_ENCODER=OFF \
	-DWITH_KVAZAAR=OFF \
	-DWITH_LIBDE265=OFF \
	-DWITH_LIBSHARPYUV=OFF \
	-DWITH_OpenJPEG_DECODER=OFF \
	-DWITH_OpenJPEG_ENCODER=OFF \
	-DWITH_RAV1E=OFF \
	-DWITH_REDUCED_VISIBILITY=ON \
	-DWITH_SvtEnc=OFF \
	-DWITH_X265=OFF

HOST_LIBHEIF_DEPENDENCIES = host-gdk-pixbuf host-pkgconf

$(eval $(cmake-package))
$(eval $(host-cmake-package))
