#
# Copyright (C) 2014-2018 OpenWrt-dist
# Copyright (C) 2014-2018 Jian Chang <aa65535@live.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-dns-forwarder
PKG_VERSION:=1.6.3
PKG_RELEASE:=1

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jian Chang <aa65535@live.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Create/uci-defaults
	( \
		echo '#!/bin/sh'; \
		echo 'uci -q batch <<-EOF >/dev/null'; \
		echo "	delete ucitrack.@$(1)[-1]"; \
		echo "	add ucitrack $(1)"; \
		echo "	set ucitrack.@$(1)[-1].init=$(1)"; \
		echo '	commit ucitrack'; \
		echo 'EOF'; \
		echo 'rm -f /tmp/luci-indexcache'; \
		echo 'exit 0'; \
	) > $(PKG_BUILD_DIR)/$(1)
endef

define Package/luci-app-dns-forwarder
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=Luci Support for dns-forwarder
	PKGARCH:=all
	DEPENDS:=+dns-forwarder
endef

define Package/luci-app-dns-forwarder/description
	LuCI Support for dns-forwarder.
endef

define Build/Prepare
	$(foreach po,$(wildcard ${CURDIR}/files/luci/i18n/*.po), \
		po2lmo $(po) $(PKG_BUILD_DIR)/$(patsubst %.po,%.lmo,$(notdir $(po)));)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-dns-forwarder/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	( . /etc/uci-defaults/luci-app-dns-forwarder ) && rm -f /etc/uci-defaults/luci-app-dns-forwarder
	chmod 755 /etc/init.d/dns-forwarder >/dev/null 2>&1
	/etc/init.d/dns-forwarder enable >/dev/null 2>&1
fi
exit 0
endef

define Package/luci-app-dns-forwarder/postrm
#!/bin/sh
rm -f /tmp/luci-indexcache
exit 0
endef


define Package/luci-app-dns-forwarder/install
  $(call Create/uci-defaults,luci-app-dns-forwarder)
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/luci/controller/dns-forwarder.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/dns-forwarder.*.lmo $(1)/usr/lib/lua/luci/i18n/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./files/luci/model/cbi/dns-forwarder.lua $(1)/usr/lib/lua/luci/model/cbi/
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./files/usr/share/rpcd/acl.d/luci-app-dns-forwarder.json $(1)/usr/share/rpcd/acl.d/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luci-app-dns-forwarder $(1)/etc/uci-defaults/luci-app-dns-forwarder
endef

$(eval $(call BuildPackage,luci-app-dns-forwarder))
