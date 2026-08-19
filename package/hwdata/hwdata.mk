################################################################################
#
# hwdata
#
################################################################################

HWDATA_VERSION = 0.409
HWDATA_SITE = $(call github,vcrhonek,hwdata,v$(HWDATA_VERSION))
HWDATA_LICENSE = GPL-2.0+, BSD-3-Clause, XFree86 1.0
HWDATA_LICENSE_FILES = COPYING LICENSE
HWDATA_INSTALL_STAGING = YES

HWDATA_FILES = \
	$(if $(BR2_PACKAGE_HWDATA_IAB_OUI_TXT),iab.txt oui.txt) \
	$(if $(BR2_PACKAGE_HWDATA_PCI_IDS),pci.ids) \
	$(if $(BR2_PACKAGE_HWDATA_PNP_IDS),pnp.ids) \
	$(if $(BR2_PACKAGE_HWDATA_USB_IDS),usb.ids)

define HWDATA_CONFIGURE_CMDS
	(cd $(@D); $(TARGET_CONFIGURE_OPTS) ./configure)
endef

define HWDATA_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) hwdata.pc
endef

ifneq ($(strip $(HWDATA_FILES)),)
define HWDATA_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0644 $(@D)/hwdata.pc \
		$(STAGING_DIR)/usr/lib/pkgconfig/hwdata.pc
	$(INSTALL) -d -m 755 $(STAGING_DIR)/usr/share/hwdata
	$(INSTALL) -m 644 -t $(STAGING_DIR)/usr/share/hwdata \
		$(addprefix $(@D)/,$(HWDATA_FILES))
endef
define HWDATA_INSTALL_TARGET_CMDS
	$(INSTALL) -d -m 755 $(TARGET_DIR)/usr/share/hwdata
	$(INSTALL) -m 644 -t $(TARGET_DIR)/usr/share/hwdata \
		$(addprefix $(@D)/,$(HWDATA_FILES))
endef
endif

# The host variant is for build-time consumers on the build machine.
# libdisplay-info compiles a search table out of pnp.ids and looks hwdata up
# with dependency('hwdata', native: true), falling back to the build
# machine's /usr/share/hwdata/pnp.ids - which may or may not exist there:
#
#   meson.build:24:11: ERROR: File /usr/share/hwdata/pnp.ids does not exist.
#
# Installing pnp.ids and the .pc into HOST_DIR makes the native lookup
# deterministic. The full id set is small; no options are mirrored.
define HOST_HWDATA_CONFIGURE_CMDS
	(cd $(@D); ./configure --prefix=$(HOST_DIR) --datadir=$(HOST_DIR)/share)
endef

define HOST_HWDATA_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) hwdata.pc
endef

define HOST_HWDATA_INSTALL_CMDS
	$(INSTALL) -D -m 0644 $(@D)/hwdata.pc \
		$(HOST_DIR)/share/pkgconfig/hwdata.pc
	$(INSTALL) -d -m 755 $(HOST_DIR)/share/hwdata
	$(INSTALL) -m 644 -t $(HOST_DIR)/share/hwdata \
		$(@D)/pnp.ids $(@D)/pci.ids $(@D)/usb.ids
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
