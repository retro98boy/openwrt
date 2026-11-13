include $(TOPDIR)/rules.mk

PKG_NAME:=brotli
PKG_VERSION:=1.2.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/google/brotli/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=98d35d11a78dc453aebb7d10c3748f3f73ff78c8267c0dc697b8631f67bf7e8f

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libbrotli
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Brotli compression libraries
  URL:=https://github.com/google/brotli
endef

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON \
	-DBROTLI_DISABLE_TESTS=ON

define Package/libbrotli/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libbrotli*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libbrotli))
