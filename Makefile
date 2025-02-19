include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-campus-network-login
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI app for Campus Network Login
  DEPENDS:=+luci-base +curl
  PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
  LuCI interface for campus network login with cron scheduling.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/campus_network $(1)/etc/config/campus_network
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/luasrc/controller/campus_network.lua $(1)/usr/lib/lua/luci/controller/
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/campus_network
	$(INSTALL_DATA) ./files/luasrc/model/cbi/campus_network/login.lua $(1)/usr/lib/lua/luci/model/cbi/campus_network/
	
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/campus_login.sh $(1)/usr/bin/
	
	$(INSTALL_DIR) $(1)/etc/xyw
endef

$(eval $(call BuildPackage,$(PKG_NAME)))