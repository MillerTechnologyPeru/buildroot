### Swift Demo
SWIFT_HELLO_VERSION = 0.1.0
SWIFT_HELLO_SITE = $(SWIFT_HELLO_PKGDIR)/src
SWIFT_HELLO_SITE_METHOD = local
SWIFT_HELLO_INSTALL_STAGING = NO
SWIFT_HELLO_INSTALL_TARGET = YES
SWIFT_HELLO_SUPPORTS_IN_SOURCE_BUILD = YES
SWIFT_HELLO_DEPENDENCIES = swift foundation
SWIFT_HELLO_EXECUTABLES = swift-hello
SWIFT_HELLO_BUILDDIR = $(SWIFT_HELLO_SRCDIR)/.build/$(if $(BR2_ENABLE_RUNTIME_DEBUG),debug,release)

define SWIFT_HELLO_BUILD_CMDS
	( \
	cd $(SWIFT_HELLO_SRCDIR) && \
	rm -rf .build && \
	PATH=$(BR_PATH):$(SWIFT_NATIVE_PATH) \
	$(SWIFT_NATIVE_PATH)/swift build -c $(if $(BR2_ENABLE_RUNTIME_DEBUG),debug,release) --destination $(SWIFTPM_DESTINATION_FILE) \
	)
endef

define SWIFT_HELLO_INSTALL_TARGET_CMDS
	# Copy dynamic libraries
	#cp $(SWIFT_HELLO_BUILDDIR)/*.so $(TARGET_DIR)/usr/lib/
	cp $(SWIFT_HELLO_BUILDDIR)/swift-hello $(TARGET_DIR)/usr/bin/hello
endef

define SWIFT_HELLO_INSTALL_STAGING_CMDS
	# Copy dynamic libraries
	#cp $(SWIFT_HELLO_BUILDDIR)/*.so $(STAGING_DIR)/usr/lib/swift/linux/
	cp $(SWIFT_HELLO_BUILDDIR)/swift-hello $(STAGING_DIR)/usr/bin/hello
endef

$(eval $(generic-package))
