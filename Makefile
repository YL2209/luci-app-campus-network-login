# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 Your Name <your.email@example.com>

include $(TOPDIR)/rules.mk

LUCI_TITLE:=Campus Network Login
LUCI_DEPENDS:=+curl
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-campusnet-login
PKG_VERSION:=1.0
PKG_RELEASE:=1

define Package/$(PKG_NAME)/description
This plugin provides a web interface to configure and run a campus network login script.
endef

define Package/$(PKG_NAME)/conffiles
/etc/login_config.ini
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
$(eval $(call BuildPackage,$(PKG_NAME)))