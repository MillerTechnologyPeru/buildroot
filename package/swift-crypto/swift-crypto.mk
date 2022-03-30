### Swift CryptoKit library
SWIFT_CRYPTO_VERSION = 2.0.5
SWIFT_CRYPTO_SOURCE = $(SWIFT_CRYPTO_VERSION).tar.gz
SWIFT_CRYPTO_SITE = https://github.com/apple/swift-crypto/archive/refs/tags/
SWIFT_CRYPTO_LICENSE = Apache-2.0
SWIFT_CRYPTO_LICENSE_FILES = LICENSE.txt
SWIFT_CRYPTO_INSTALL_STAGING = YES
SWIFT_CRYPTO_INSTALL_TARGET = YES
SWIFT_CRYPTO_SUPPORTS_IN_SOURCE_BUILD = YES
SWIFT_CRYPTO_DEPENDENCIES = swift foundation
SWIFT_CRYPTO_BUILDDIR = $(SWIFT_CRYPTO_SRCDIR)/.build/$(if $(BR2_ENABLE_RUNTIME_DEBUG),debug,release)

define SWIFT_CRYPTO_BUILD_CMDS
	( \
	cd $(SWIFT_CRYPTO_SRCDIR) && \
	rm -rf .build && \
	PATH=$(BR_PATH):$(SWIFT_NATIVE_PATH) \
	$(SWIFT_NATIVE_PATH)/swift build -c $(if $(BR2_ENABLE_RUNTIME_DEBUG),debug,release) --destination $(SWIFT_DESTINATION_FILE) \
	)
endef

define SWIFT_CRYPTO_INSTALL_TARGET_CMDS
	# Copy dynamic libraries
	cp -rf $(SWIFT_CRYPTO_BUILDDIR)/libCrypto.so $(TARGET_DIR)/usr/lib/
endef

define SWIFT_CRYPTO_INSTALL_STAGING_CMDS
	# Copy dynamic libraries
	cp -rf $(SWIFT_CRYPTO_BUILDDIR)/libCrypto.so $(STAGING_DIR)/usr/lib/swift/linux/
	# Copy Swift module
	cp -rf $(SWIFT_CRYPTO_BUILDDIR)/Crypto.swiftdoc ${STAGING_DIR}/usr/lib/swift/linux/$(SWIFT_TARGET_ARCH)/
	cp -rf $(SWIFT_CRYPTO_BUILDDIR)/Crypto.swiftmodule ${STAGING_DIR}/usr/lib/swift/linux/$(SWIFT_TARGET_ARCH)/
	cp -rf $(SWIFT_CRYPTO_BUILDDIR)/Crypto.swiftsourceinfo ${STAGING_DIR}/usr/lib/swift/linux/$(SWIFT_TARGET_ARCH)/
endef

$(eval $(generic-package))
