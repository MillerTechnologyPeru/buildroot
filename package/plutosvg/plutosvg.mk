################################################################################
#
# plutosvg
#
################################################################################

PLUTOSVG_VERSION = 0.0.8
PLUTOSVG_SITE = $(call github,sammycage,plutosvg,v$(PLUTOSVG_VERSION))
PLUTOSVG_LICENSE = MIT
PLUTOSVG_LICENSE_FILES = LICENSE
PLUTOSVG_INSTALL_STAGING = YES
PLUTOSVG_DEPENDENCIES = host-pkgconf freetype plutovg

PLUTOSVG_CONF_OPTS = \
	-DPLUTOSVG_ENABLE_FREETYPE=ON \
	-DPLUTOSVG_BUILD_EXAMPLES=OFF

$(eval $(cmake-package))
