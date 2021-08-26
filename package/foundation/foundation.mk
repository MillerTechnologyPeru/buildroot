### Foundation
FOUNDATION_VERSION = $(call qstrip,$(BR2_PACKAGE_SWIFT_VERSION))
FOUNDATION_SOURCE = swift-$(SWIFT_VERSION)-RELEASE.tar.gz
FOUNDATION_SITE = https://github.com/apple/swift-corelibs-foundation/archive/refs/tags
FOUNDATION_INSTALL_STAGING = YES
FOUNDATION_INSTALL_TARGET = YES
FOUNDATION_SUPPORTS_IN_SOURCE_BUILD = NO
FOUNDATION_DEPENDENCIES = swift libdispatch

FOUNDATION_CONF_OPTS += \
    -DCMAKE_Swift_FLAGS=${SWIFTC_FLAGS} \
    -DCF_DEPLOYMENT_SWIFT=ON \
    -Ddispatch_DIR="$(LIBDISPATCH_BUILDDIR)/cmake/modules" \
    -DICU_I18N_LIBRARY_RELEASE=${STAGING_DIR}/usr/lib/ibicui18n.so \
    -DICU_UC_LIBRARY_RELEASE=${STAGING_DIR}/usr/lib/libicuuc.so \
    -DICU_I18N_LIBRARY_DEBUG=${STAGING_DIR}/usr/lib/ibicui18n.so \
    -DICU_UC_LIBRARY_DEBUG=${STAGING_DIR}/usr/lib/libicuuc.so \
    -DICU_INCLUDE_DIR="${STAGING_DIR}/usr/include" \

ifeq ($(BR2_PACKAGE_LIBCURL),y)
	FOUNDATION_DEPENDENCIES += libcurl
	FOUNDATION_CONF_OPTS += \
    	-DCURL_LIBRARY_RELEASE=${STAGING_DIR}/usr/lib/libcurl.so \
    	-DCURL_INCLUDE_DIR="${STAGING_DIR}/usr/include" \

endif

ifeq ($(BR2_PACKAGE_LIBXML2),y)
	FOUNDATION_DEPENDENCIES += libxml2
	FOUNDATION_CONF_OPTS += \
		-DLIBXML2_LIBRARY=${STAGING_DIR}/usr/lib/libxml2.so \
    	-DLIBXML2_INCLUDE_DIR=${STAGING_DIR}/usr/include/libxml2 \
	
endif

ifeq (FOUNDATION_SUPPORTS_IN_SOURCE_BUILD),YES)
FOUNDATION_BUILDDIR			= $(FOUNDATION_SRCDIR)
else
FOUNDATION_BUILDDIR			= $(FOUNDATION_SRCDIR)/build
endif

define FOUNDATION_CONFIGURE_CMDS
	(mkdir -p $(FOUNDATION_BUILDDIR) && \
	cd $(FOUNDATION_BUILDDIR) && \
	rm -f CMakeCache.txt && \
	PATH=$(BR_PATH) \
	$(FOUNDATION_CONF_ENV) $(BR2_CMAKE) -S $(FOUNDATION_SRCDIR) -B $(FOUNDATION_BUILDDIR) -G Ninja \
		-DCMAKE_INSTALL_PREFIX="/usr" \
		-DBUILD_SHARED_LIBS=ON \
		-DCMAKE_BUILD_TYPE=$(if $(BR2_ENABLE_RUNTIME_DEBUG),Debug,Release) \
    	-DCMAKE_C_COMPILER=$(SWIFT_NATIVE_PATH)/usr/bin/clang \
    	-DCMAKE_C_FLAGS="-w -fuse-ld=lld -target $(GNU_TARGET_NAME) --sysroot=$(STAGING_DIR) -I$(STAGING_DIR)/usr/include -B$(STAGING_DIR)/usr/lib -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION))" \
    	-DCMAKE_C_LINK_FLAGS="-target $(GNU_TARGET_NAME) --sysroot=$(STAGING_DIR)" \
		-DCMAKE_ASM_FLAGS="-target $(GNU_TARGET_NAME) --sysroot=$(STAGING_DIR)" \
		$(FOUNDATION_CONF_OPTS) \
	)
endef

define FOUNDATION_BUILD_CMDS
	(cd $(FOUNDATION_BUILDDIR) && ninja)
endef

define FOUNDATION_INSTALL_TARGET_CMDS
	(cd $(FOUNDATION_BUILDDIR) && \
	cp ./*.so $(TARGET_DIR)/usr/lib/ \
	)
endef

define FOUNDATION_INSTALL_STAGING_CMDS
	(cd $(FOUNDATION_BUILDDIR) && \
		cp ./*.so $(STAGING_DIR)/usr/lib/swift/linux/ && \
		cp ./src/swift/swift/* ${STAGING_DIR}/usr/lib/swift/linux/$(SWIFT_TARGET_ARCH)/ && \
		mkdir ${STAGING_DIR}/usr/lib/swift/linux/dispatch && \
		cp $(FOUNDATION_SRCDIR)/dispatch/*.h ${STAGING_DIR}/usr/lib/swift/linux/dispatch/ && \
		cp $(FOUNDATION_SRCDIR)/dispatch/module.modulemap ${STAGING_DIR}/usr/lib/swift/linux/dispatch/ \
		)
endef

$(eval $(generic-package))
