#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI app for Campus Network Login
LUCI_DEPENDS:=+luci-base +curl
LUCI_PKGARCH:=all
PKG_VERSION:=1.4
PKG_RELEASE:=1
EXTRA_DEPENDS:=+campus_network +luci-compat

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
