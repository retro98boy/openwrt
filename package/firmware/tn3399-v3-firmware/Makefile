include $(TOPDIR)/rules.mk

PKG_NAME:=brcmfmac-firmware-tn3399-v3

PKG_SOURCE_URL:=https://github.com/armbian/firmware.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=0c5a7e40793d35c2f1209772d68bf04ad769a777
# sha256sum
PKG_MIRROR_HASH:=113acf41b2ecb0b17e53de36265caa8e0d8af600e8d02df499a8e98d855f7a7f

include $(INCLUDE_DIR)/package.mk

define Package/brcmfmac-firmware-tn3399-v3
  SECTION:=firmware
  CATEGORY:=Firmware
  URL:=https://github.com/armbian/firmware.git
  TITLE:=TIANNUO TN3399_V3 AP6255 Firmware
endef

define Build/Compile
	true
endef

define Package/brcmfmac-firmware-tn3399-v3/install
	$(INSTALL_DIR) $(1)/lib/firmware/brcm
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/BCM4345C0.hcd \
		$(1)/lib/firmware/brcm/BCM4345C0.hcd
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/brcm/brcmfmac43455-sdio.clm_blob \
		$(1)/lib/firmware/brcm/brcmfmac43455-sdio.clm_blob
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/brcm/brcmfmac43455-sdio.bin \
		$(1)/lib/firmware/brcm/brcmfmac43455-sdio.tiannuo,tn3399-v3.bin
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/brcm/brcmfmac43455-sdio.txt \
		$(1)/lib/firmware/brcm/brcmfmac43455-sdio.tiannuo,tn3399-v3.txt
endef

$(eval $(call BuildPackage,brcmfmac-firmware-tn3399-v3))
