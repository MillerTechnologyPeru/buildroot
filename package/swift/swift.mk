### Apple's Swift Programming Language
SWIFT_VERSION =  $(call qstrip,$(BR2_PACKAGE_SWIFT_VERSION))
SWIFT_TARGET_ARCH = $(call qstrip,$(BR2_PACKAGE_SWIFT_TARGET_ARCH))
SWIFT_NATIVE_PATH = $(call qstrip,$(BR2_PACKAGE_SWIFT_NATIVE_TOOLS))
SWIFT_SOURCE = swift-$(SWIFT_VERSION)-RELEASE.tar.gz
SWIFT_SITE = https://github.com/apple/swift/archive/refs/tags
SWIFT_INSTALL_STAGING = YES
SWIFT_INSTALL_TARGET = YES
SWIFT_SUPPORTS_IN_SOURCE_BUILD = NO
SWIFT_DEPENDENCIES = icu
ifeq ($(BR2_TOOLCHAIN_HAS_LIBATOMIC),y)
SWIFT_CONF_ENV += LIBS="-latomic"
endif

SWIFT_TARGET_FLAGS=--sysroot=$(STAGING_DIR)
SWIFT_EXTRA_INCLUDE_FLAGS=-I$(STAGING_DIR)/usr/include
SWIFT_RUNTIME_FLAGS=-w -fuse-ld=lld $(SWIFT_TARGET_FLAGS) -B$(STAGING_DIR)/usr/lib -B$(STAGING_DIR)/lib -B$(HOST_DIR)/lib/gcc/aarch64-buildroot-linux-gnu/10.3.0
SWIFT_LINK_FLAGS=$(SWIFT_TARGET_FLAGS)

SWIFT_CONF_OPTS +=  \
    -DSWIFT_USE_LINKER=lld \
    -DLLVM_USE_LINKER=lld \
    -DLLVM_DIR=/usr/lib/llvm-10/lib/cmake/llvm \
    -DLLVM_BUILD_LIBRARY_DIR=/usr/lib/llvm-10 \
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

ifeq (SWIFT_SUPPORTS_IN_SOURCE_BUILD),YES)
SWIFT_BUILDDIR			= $(SWIFT_SRCDIR)
else
SWIFT_BUILDDIR			= $(SWIFT_SRCDIR)/buildroot-build
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
    		-DCMAKE_C_FLAGS="-I$(STAGING_DIR)/usr/include -I/home/coleman/Developer/buildroot/output/host/aarch64-buildroot-linux-gnu/include/c++/10.3.0" \
    		-DCMAKE_CXX_FLAGS="-I$(STAGING_DIR)/usr/include -I/home/coleman/Developer/buildroot/output/host/aarch64-buildroot-linux-gnu/include/c++/10.3.0" \
    		-DCMAKE_C_LINK_FLAGS="" \
    		-DCMAKE_CXX_LINK_FLAGS="" \
		$(SWIFT_CONF_OPTS) \
	)
endef

define SWIFT_BUILD_CMDS
	(cd $(SWIFT_BUILDDIR) && ninja)
endef

define SWIFT_INSTALL_TARGET_CMDS
	(cd $(SWIFT_BUILDDIR) && \
	cp ./lib/swift/linux/libswiftCore.so $(TARGET_DIR)/usr/lib && \
	cp ./lib/swift/linux/libswiftRemoteMirror.so $(TARGET_DIR)/usr/lib && \
	cp ./lib/swift/linux/libswiftSwiftOnoneSupport.so $(TARGET_DIR)/usr/lib \
	)
endef

define SWIFT_INSTALL_STAGING_CMDS
	(cd $(SWIFT_BUILDDIR) && \
	mkdir ${STAGING_DIR}/usr/lib/swift && \
	mkdir ${STAGING_DIR}/usr/lib/swift/linux && \
	cp -rf ./lib/swift/shims ${STAGING_DIR}/usr/lib/swift/ && \
	cp ./lib/swift/linux/libswiftCore.so ${STAGING_DIR}/usr/lib/swift/linux/ && \
	cp ./lib/swift/linux/libswiftRemoteMirror.so ${STAGING_DIR}/usr/lib/swift/linux/ && \
	cp ./lib/swift/linux/libswiftSwiftOnoneSupport.so ${STAGING_DIR}/usr/lib/swift/linux/ && \
	cp -rf ./lib/swift/linux/Glibc.swiftmodule ${STAGING_DIR}/usr/lib/swift/linux/ && \
	cp -rf ./lib/swift/linux/Swift.swiftmodule ${STAGING_DIR}/usr/lib/swift/linux/ && \
	cp -rf ./lib/swift/linux/SwiftOnoneSupport.swiftmodule ${STAGING_DIR}/usr/lib/swift/linux/ && \
	mkdir ${STAGING_DIR}/usr/lib/swift/linux/$(SWIFT_TARGET_ARCH) && \
	cp ./lib/swift/linux/$(SWIFT_TARGET_ARCH)/glibc.modulemap ${STAGING_DIR}/usr/lib/swift/linux/$(SWIFT_TARGET_ARCH)/ && \
	cp ./lib/swift/linux/$(SWIFT_TARGET_ARCH)/swiftrt.o ${STAGING_DIR}/usr/lib/swift/linux/$(SWIFT_TARGET_ARCH)/ \
	)
endef

$(eval $(generic-package))
