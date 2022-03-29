### Grand Central Dispatch
LIBDISPATCH_VERSION = 5.6
LIBDISPATCH_SITE = $(call github,apple,swift-corelibs-libdispatch,swift-$(LIBDISPATCH_VERSION)-RELEASE)
LIBDISPATCH_LICENSE = Apache-2.0
LIBDISPATCH_LICENSE_FILES = LICENSE
LIBDISPATCH_INSTALL_STAGING = YES
LIBDISPATCH_SUPPORTS_IN_SOURCE_BUILD = NO
LIBDISPATCH_DEPENDENCIES = host-clang host-lld libbsd

LIBDISPATCH_TARGET_ARCH = $(call qstrip,$(BR2_PACKAGE_LIBDISPATCH_TARGET_ARCH))
LIBDISPATCH_CLANG_PATH = $(HOST_DIR)/bin

ifeq ($(LIBDISPATCH_TARGET_ARCH),armv7)
LIBDISPATCH_TARGET_NAME		= armv7-unknown-linux-gnueabihf
else ifeq ($(LIBDISPATCH_TARGET_ARCH),armv6)
LIBDISPATCH_TARGET_NAME		= armv6-unknown-linux-gnueabihf
else ifeq ($(LIBDISPATCH_TARGET_ARCH),armv5)
LIBDISPATCH_TARGET_NAME		= armv5-unknown-linux-gnueabi
else
LIBDISPATCH_TARGET_NAME		= $(LIBDISPATCH_TARGET_ARCH)-unknown-linux-gnu
endif

ifeq ($(LIBDISPATCH_TARGET_ARCH),armv5)
LIBDISPATCH_EXTRA_FLAGS		= -march=armv5te
else ifeq ($(LIBDISPATCH_TARGET_ARCH),riscv64)
LIBDISPATCH_EXTRA_FLAGS		= -mno-relax -mabi=lp64 -march=rv64imac -mfloat-abi=soft
else ifeq ($(LIBDISPATCH_TARGET_ARCH),mipsel)
LIBDISPATCH_EXTRA_FLAGS		= -msoft-float
else ifeq ($(LIBDISPATCH_TARGET_ARCH),mips64el)
LIBDISPATCH_EXTRA_FLAGS		= -msoft-float
else ifeq ($(LIBDISPATCH_TARGET_ARCH),powerpc)
LIBDISPATCH_EXTRA_FLAGS		= -mcpu=7400
else
LIBDISPATCH_EXTRA_FLAGS		= 
endif

LIBDISPATCH_CONF_OPTS += \
	-DLibRT_LIBRARIES="${STAGING_DIR}/usr/lib/librt.a" \
	-DCMAKE_C_COMPILER=$(LIBDISPATCH_CLANG_PATH)/clang \
	-DCMAKE_CXX_COMPILER=$(LIBDISPATCH_CLANG_PATH)/clang++ \
	-DCMAKE_C_FLAGS="-w -fuse-ld=lld $(LIBDISPATCH_EXTRA_FLAGS) -target $(LIBDISPATCH_TARGET_NAME) --sysroot=$(STAGING_DIR) -I$(STAGING_DIR)/usr/include -B$(STAGING_DIR)/usr/lib -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION))" \
	-DCMAKE_C_LINK_FLAGS="-target $(LIBDISPATCH_TARGET_NAME) --sysroot=$(STAGING_DIR)" \
	-DCMAKE_CXX_FLAGS="-w -fuse-ld=lld $(LIBDISPATCH_EXTRA_FLAGS) -target $(LIBDISPATCH_TARGET_NAME) --sysroot=$(STAGING_DIR) -I$(STAGING_DIR)/usr/include -I$(HOST_DIR)/$(GNU_TARGET_NAME)/include/c++/$(call qstrip,$(BR2_GCC_VERSION))/ -I$(HOST_DIR)/$(GNU_TARGET_NAME)/include/c++/$(call qstrip,$(BR2_GCC_VERSION))/$(GNU_TARGET_NAME) -B$(STAGING_DIR)/usr/lib -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION))" \
	-DCMAKE_CXX_LINK_FLAGS="-target $(LIBDISPATCH_TARGET_NAME) --sysroot=$(STAGING_DIR)" \

define LIBDISPATCH_INSTALL_TARGET_CMDS
	(cd $(LIBDISPATCH_BUILDDIR) && \
	cp ./*.so $(TARGET_DIR)/usr/lib/ \
	)
endef

$(eval $(cmake-package))
