Package/rockchip-cdn-dp-firmware = $(call Package/firmware-default,Rockchip cdn DP firmware)
define Package/rockchip-cdn-dp-firmware/install
	$(INSTALL_DIR) $(1)/lib/firmware/rockchip
	$(CP) \
		$(PKG_BUILD_DIR)/rockchip/dptx.bin \
		$(1)/lib/firmware/rockchip
endef

$(eval $(call BuildPackage,rockchip-cdn-dp-firmware))
