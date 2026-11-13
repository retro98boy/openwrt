include $(TOPDIR)/rules.mk

PKG_NAME:=android-tools
PKG_VERSION:=35.0.2
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/nmeum/android-tools/releases/download/$(PKG_VERSION)
PKG_HASH:=d2c3222280315f36d8bfa5c02d7632b47e365bfe2e77e99a3564fb6576f04097

PKG_LICENSE:=Apache-2.0 GPL-2.0-only LGPL-2.0-only BSD-3-Clause ISC MIT OpenSSL
PKG_LICENSE_FILES:=LICENSE vendor/boringssl/LICENSE vendor/fmtlib/LICENSE \
	vendor/e2fsprogs/NOTICE vendor/f2fs-tools/COPYING
PKG_BUILD_DEPENDS:=abseil-cpp protobuf/host
PKG_BUILD_PARALLEL:=1
CMAKE_BINARY_SUBDIR:=build

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/android-tools
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Android Debug Bridge and fastboot clients
  URL:=https://github.com/nmeum/android-tools
  DEPENDS:=+libstdcpp +libusb-1.0 +libpcre2 +zlib +protobuf \
	+liblz4 +libzstd +libbrotli
  PROVIDES:=fastboot
  CONFLICTS:=adb
endef

define Package/android-tools/description
  Android Debug Bridge and fastboot clients with filesystem image helpers.
endef

CMAKE_OPTIONS += \
	-DBUILD_TESTING=OFF \
	-DANDROID_TOOLS_PATCH_VENDOR=OFF \
	-DANDROID_TOOLS_USE_BUNDLED_FMT=ON \
	-DProtobuf_PROTOC_EXECUTABLE=$(STAGING_DIR_HOSTPKG)/bin/protoc

TARGET_CFLAGS += -I$(PKG_BUILD_DIR)/vendor/boringssl/third_party/googletest/googletest/include
TARGET_CXXFLAGS += -I$(PKG_BUILD_DIR)/vendor/boringssl/third_party/googletest/googletest/include

define Build/Compile
	$(call Build/Compile/Default,adb fastboot mke2fs.android make_f2fs)
endef

define Package/android-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(CMAKE_BINARY_DIR)/vendor/adb $(1)/usr/bin/
	$(INSTALL_BIN) $(CMAKE_BINARY_DIR)/vendor/fastboot $(1)/usr/bin/
	$(INSTALL_BIN) $(CMAKE_BINARY_DIR)/vendor/mke2fs.android $(1)/usr/bin/
	$(INSTALL_BIN) $(CMAKE_BINARY_DIR)/vendor/make_f2fs $(1)/usr/bin/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/vendor/e2fsprogs/misc/mke2fs.conf.in $(1)/usr/bin/mke2fs.conf
endef

$(eval $(call BuildPackage,android-tools))
