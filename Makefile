include $(TOPDIR)/rules.mk

PKG_NAME:=rustscan
PKG_VERSION:=2.4.1
PKG_RELEASE:=1

PKG_SOURCE:=master.tar.gz
PKG_SOURCE_URL:=https://github.com/bee-san/RustScan/archive/refs/heads/
PKG_HASH:=skip
PKG_BUILD_DIR:=$(BUILD_DIR)/RustScan-master

PKG_MAINTAINER:=ntbowen <https://github.com/ntbowen>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

define Package/rustscan
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Network Scanners
  TITLE:=The Modern Port Scanner
  URL:=https://github.com/bee-san/RustScan
  DEPENDS:=+libc
  PKGARCH:=all
endef

define Package/rustscan/description
  RustScan is a modern take on the port scanner. Sleek & fast.
  
  Features:
  - Faster than nmap
  - Adaptive learning
  - Scriptable with multiple languages
  - Cross-platform support
  - Low resource usage
endef

define Package/rustscan/conffiles
/etc/config/rustscan
endef

# Rust build configuration
RUST_PKG_FEATURES:=

define Build/Compile
	$(call Build/Compile/Cargo,,$(RUST_PKG_FEATURES))
endef

define Package/rustscan/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/rustscan $(1)/usr/bin/
	
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/rustscan.config $(1)/etc/config/rustscan
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/rustscan.init $(1)/etc/init.d/rustscan
	
	$(INSTALL_DIR) $(1)/etc/rustscan
	$(INSTALL_CONF) ./files/rustscan.toml $(1)/etc/rustscan/
endef

$(eval $(call BuildPackage,rustscan))
