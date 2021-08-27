### Apple's Swift Programming Language
SWIFT_VERSION =  $(call qstrip,$(BR2_PACKAGE_SWIFT_VERSION))
SWIFT_TARGET_ARCH = $(call qstrip,$(BR2_PACKAGE_SWIFT_TARGET_ARCH))
SWIFT_NATIVE_PATH = $(call qstrip,$(BR2_PACKAGE_SWIFT_NATIVE_TOOLS))
SWIFT_LLVM_DIR = $(call qstrip,$(BR2_PACKAGE_SWIFT_LLVM_DIR))
SWIFT_SOURCE = swift-$(SWIFT_VERSION)-RELEASE.tar.gz
SWIFT_SITE = https://github.com/apple/swift/archive/refs/tags
SWIFT_INSTALL_STAGING = YES
SWIFT_INSTALL_TARGET = YES
SWIFT_SUPPORTS_IN_SOURCE_BUILD = NO
SWIFT_DEPENDENCIES = icu
ifeq ($(BR2_TOOLCHAIN_HAS_LIBATOMIC),y)
SWIFT_CONF_ENV += LIBS="-latomic"
endif

SWIFT_CONF_OPTS +=  \
    -DSWIFT_USE_LINKER=lld \
    -DLLVM_USE_LINKER=lld \
    -DLLVM_DIR=$(SWIFT_LLVM_DIR)/lib/cmake/llvm \
    -DLLVM_BUILD_LIBRARY_DIR=$(SWIFT_LLVM_DIR) \
    -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON \
    -DSWIFT_BUILD_RUNTIME_WITH_HOST_COMPILER=ON \
    -DSWIFT_NATIVE_CLANG_TOOLS_PATH=$(SWIFT_NATIVE_PATH)/usr/bin \
    -DSWIFT_NATIVE_SWIFT_TOOLS_PATH=$(SWIFT_NATIVE_PATH)/usr/bin \
    -DSWIFT_BUILD_AST_ANALYZER=OFF \
    -DSWIFT_BUILD_DYNAMIC_SDK_OVERLAY=ON \
    -DSWIFT_BUILD_DYNAMIC_STDLIB=ON \
    -DSWIFT_BUILD_REMOTE_MIRROR=OFF \
    -DSWIFT_BUILD_SOURCEKIT=OFF \
    -DSWIFT_BUILD_STDLIB_EXTRA_TOOLCHAIN_CONTENT=OFF \
    -DSWIFT_BUILD_SYNTAXPARSERLIB=OFF \
    -DSWIFT_BUILD_REMOTE_MIRROR=OFF \
    -DSWIFT_ENABLE_SOURCEKIT_TESTS=OFF \
    -DSWIFT_INCLUDE_DOCS=OFF \
    -DSWIFT_INCLUDE_TOOLS=OFF \
    -DSWIFT_INCLUDE_TESTS=OFF \
    -DSWIFT_LIBRARY_EVOLUTION=0 \
    -DSWIFT_RUNTIME_OS_VERSIONING=OFF \
    -DSWIFT_HOST_VARIANT_ARCH=$(SWIFT_TARGET_ARCH) \
    -DSWIFT_SDKS=LINUX \
    -DSWIFT_SDK_LINUX_ARCH_$(SWIFT_TARGET_ARCH)_PATH=${STAGING_DIR}  \
    -DSWIFT_SDK_LINUX_ARCH_$(SWIFT_TARGET_ARCH)_LIBC_INCLUDE_DIRECTORY=${STAGING_DIR}/usr/include  \
    -DSWIFT_SDK_LINUX_ARCH_$(SWIFT_TARGET_ARCH)_LIBC_ARCHITECTURE_INCLUDE_DIRECTORY=${STAGING_DIR}/usr/include \
    -DSWIFT_LINUX_$(SWIFT_TARGET_ARCH)_ICU_I18N=${STAGING_DIR}/usr/lib/libicui18n.so \
    -DSWIFT_LINUX_$(SWIFT_TARGET_ARCH)_ICU_UC=${STAGING_DIR}/usr/lib/libicuuc.so \
    -DICU_I18N_LIBRARIES=${STAGING_DIR}/usr/lib/libicui18n.so \
    -DICU_UC_LIBRARIES=${STAGING_DIR}/usr/lib/libicuuc.so \

ifeq ($(SWIFT_TARGET_ARCH),armv7)
SWIFT_TARGET_NAME		= armv7-unknown-linux-gnueabihf
else
SWIFT_TARGET_NAME		= $(SWIFT_TARGET_ARCH)-unknown-linux-gnu
endif

SWIFTC_FLAGS="-target $(SWIFT_TARGET_NAME) -use-ld=lld \
-resource-dir ${STAGING_DIR}/usr/lib/swift \
-Xclang-linker -B${STAGING_DIR}/usr/lib \
-Xclang-linker -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) \
-Xcc -I${STAGING_DIR}/usr/include \
-Xcc -I$(HOST_DIR)/$(GNU_TARGET_NAME)/include/c++/$(call qstrip,$(BR2_GCC_VERSION)) \
-Xcc -I$(HOST_DIR)/$(GNU_TARGET_NAME)/include/c++/$(call qstrip,$(BR2_GCC_VERSION))/$(GNU_TARGET_NAME) \
-L${STAGING_DIR}/lib \
-L${STAGING_DIR}/usr/lib \
-L${STAGING_DIR}/usr/lib/swift \
-L${STAGING_DIR}/usr/lib/swift/linux \
-L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) \
-sdk ${STAGING_DIR} \
"

HOST_SWIFT_SUPPORT_DIR = $(HOST_DIR)/usr/share/swift
SWIFTPM_DESTINATION_FILE = $(HOST_SWIFT_SUPPORT_DIR)/$(SWIFT_TARGET_NAME)-toolchain.json

ifeq (SWIFT_SUPPORTS_IN_SOURCE_BUILD),YES)
SWIFT_BUILDDIR			= $(SWIFT_SRCDIR)
else
SWIFT_BUILDDIR			= $(SWIFT_SRCDIR)/build
endif

define SWIFT_CONFIGURE_CMDS
	(mkdir -p $(SWIFT_BUILDDIR) && \
	cd $(SWIFT_BUILDDIR) && \
	rm -f CMakeCache.txt && \
	PATH=$(BR_PATH) \
	$(SWIFT_CONF_ENV) $(BR2_CMAKE) -S $(SWIFT_SRCDIR) -B $(SWIFT_BUILDDIR) -G Ninja \
		-DCMAKE_INSTALL_PREFIX="/usr" \
		-DCMAKE_COLOR_MAKEFILE=OFF \
		-DBUILD_DOC=OFF \
		-DBUILD_DOCS=OFF \
		-DBUILD_EXAMPLE=OFF \
		-DBUILD_EXAMPLES=OFF \
		-DBUILD_TEST=OFF \
		-DBUILD_TESTS=OFF \
		-DBUILD_TESTING=OFF \
		-DBUILD_SHARED_LIBS=ON \
		-DCMAKE_BUILD_TYPE=$(if $(BR2_ENABLE_RUNTIME_DEBUG),Debug,Release) \
    		-DCMAKE_C_COMPILER=$(SWIFT_NATIVE_PATH)/usr/bin/clang \
    		-DCMAKE_CXX_COMPILER=$(SWIFT_NATIVE_PATH)/usr/bin/clang++ \
    		-DCMAKE_C_FLAGS="-w -fuse-ld=lld -target $(GNU_TARGET_NAME) --sysroot=$(STAGING_DIR) -I$(STAGING_DIR)/usr/include -B$(STAGING_DIR)/usr/lib -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION))" \
    		-DCMAKE_C_LINK_FLAGS="-target $(GNU_TARGET_NAME) --sysroot=$(STAGING_DIR)" \
    		-DCMAKE_CXX_FLAGS="-w -fuse-ld=lld -target $(GNU_TARGET_NAME) --sysroot=$(STAGING_DIR) -I$(STAGING_DIR)/usr/include -I$(HOST_DIR)/$(GNU_TARGET_NAME)/include/c++/$(call qstrip,$(BR2_GCC_VERSION))/ -I$(HOST_DIR)/$(GNU_TARGET_NAME)/include/c++/$(call qstrip,$(BR2_GCC_VERSION))/$(GNU_TARGET_NAME) -B$(STAGING_DIR)/usr/lib -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION))" \
    		-DCMAKE_CXX_LINK_FLAGS="-target $(GNU_TARGET_NAME) --sysroot=$(STAGING_DIR)" \
		$(SWIFT_CONF_OPTS) \
	)
endef

define SWIFT_BUILD_CMDS
	(cd $(SWIFT_BUILDDIR) && ninja)
endef

define SWIFT_INSTALL_TARGET_CMDS
	(cd $(SWIFT_BUILDDIR) && \
	cp ./lib/swift/linux/*.so $(TARGET_DIR)/usr/lib \
	)
endef

define SWIFT_INSTALL_STAGING_CMDS
	# Copy runtime libraries and swift interfaces
	cp -rf $(SWIFT_BUILDDIR)/lib/swift ${STAGING_DIR}/usr/lib/
	# Generate SwiftPM cross compilation toolchain file
	mkdir -p $(HOST_SWIFT_SUPPORT_DIR)
	rm -f $(SWIFTPM_DESTINATION_FILE)
	touch $(SWIFTPM_DESTINATION_FILE)
	echo '{' >> $(SWIFTPM_DESTINATION_FILE)
	echo '   "version":1,' >> $(SWIFTPM_DESTINATION_FILE)
	echo '   "sdk":"$(STAGING_DIR)",' >> $(SWIFTPM_DESTINATION_FILE)
	echo '   "toolchain-bin-dir":"$(SWIFT_NATIVE_PATH)/usr/bin",' >> $(SWIFTPM_DESTINATION_FILE)
	echo '   "target":"$(SWIFT_TARGET_NAME)",' >> $(SWIFTPM_DESTINATION_FILE)
	echo '   "dynamic-library-extension":"so",' >> $(SWIFTPM_DESTINATION_FILE)
	echo '   "extra-cc-flags":[' >> $(SWIFTPM_DESTINATION_FILE)
	echo '      "-fPIC"' >> $(SWIFTPM_DESTINATION_FILE)
	echo '   ],' >> $(SWIFTPM_DESTINATION_FILE)
	echo '   "extra-swiftc-flags":[' >> $(SWIFTPM_DESTINATION_FILE)
	echo '      "-target", "$(SWIFT_TARGET_NAME)",' >> $(SWIFTPM_DESTINATION_FILE)
	echo '      "-use-ld=lld",' >> $(SWIFTPM_DESTINATION_FILE)
	echo '      "-tools-directory", "/usr/bin",' >> $(SWIFTPM_DESTINATION_FILE)
	echo '      "-Xlinker", "-rpath", "-Xlinker", "/usr/lib/swift/linux",' >> $(SWIFTPM_DESTINATION_FILE)
	echo '      "-Xlinker", "-L$(STAGING_DIR)",' >> $(SWIFTPM_DESTINATION_FILE)
	echo '      "-Xlinker", "-L$(STAGING_DIR)/lib",' >> $(SWIFTPM_DESTINATION_FILE)
	echo '      "-Xlinker", "-L$(STAGING_DIR)/usr/lib",' >> $(SWIFTPM_DESTINATION_FILE)
	echo '      "-Xlinker", "-L$(STAGING_DIR)/usr/lib/swift/linux",' >> $(SWIFTPM_DESTINATION_FILE)
	echo '      "-Xlinker", "-L$(STAGING_DIR)/usr/lib/swift/linux/$(SWIFT_TARGET_ARCH)",' >> $(SWIFTPM_DESTINATION_FILE)
	echo '      "-Xlinker", "--build-id=sha1",' >> $(SWIFTPM_DESTINATION_FILE)
	echo '      "-I$(STAGING_DIR)/usr/include",' >> $(SWIFTPM_DESTINATION_FILE)
	echo '      "-I$(STAGING_DIR)/usr/lib/swift",' >> $(SWIFTPM_DESTINATION_FILE)
	echo '      "-resource-dir", "$(STAGING_DIR)/usr/lib/swift",' >> $(SWIFTPM_DESTINATION_FILE)
	echo '      "-Xclang-linker", "-B$(STAGING_DIR)/usr/lib",' >> $(SWIFTPM_DESTINATION_FILE)
	echo '      "-sdk", "$(STAGING_DIR)"' >> $(SWIFTPM_DESTINATION_FILE)
	echo '   ],' >> $(SWIFTPM_DESTINATION_FILE)
	echo '   "extra-cpp-flags":[' >> $(SWIFTPM_DESTINATION_FILE)
	echo '      "-lstdc++"' >> $(SWIFTPM_DESTINATION_FILE)
	echo '   ]' >> $(SWIFTPM_DESTINATION_FILE)
	echo '}' >> $(SWIFTPM_DESTINATION_FILE)

endef

$(eval $(generic-package))
