#!/bin/bash
clear

## Prepare
# Update feeds
./scripts/feeds update -a && ./scripts/feeds install -a
# Irqbalance
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config
# Disable Mitigations
sed -i 's,rootwait,rootwait mitigations=off,g' target/linux/rockchip/image/mmc.bootscript
sed -i 's,rootwait,rootwait mitigations=off,g' target/linux/rockchip/image/nanopi-r2s.bootscript
sed -i 's,rootwait,rootwait mitigations=off,g' target/linux/rockchip/image/nanopi-r4s.bootscript
sed -i 's,noinitrd,noinitrd mitigations=off,g' target/linux/x86/image/grub-efi.cfg
sed -i 's,noinitrd,noinitrd mitigations=off,g' target/linux/x86/image/grub-iso.cfg
sed -i 's,noinitrd,noinitrd mitigations=off,g' target/linux/x86/image/grub-pc.cfg
# Victoria's Secret
rm -rf ./scripts/download.pl
rm -rf ./include/download.mk
wget -P scripts/ https://github.com/immortalwrt/immortalwrt/raw/openwrt-21.02/scripts/download.pl
wget -P include/ https://github.com/immortalwrt/immortalwrt/raw/openwrt-21.02/include/download.mk
sed -i '/mirror02/d' scripts/download.pl
echo "net.netfilter.nf_conntrack_helper=1" >> ./package/kernel/linux/files/sysctl-nf-conntrack.conf
sed -i 's/default NODEJS_ICU_SMALL/default NODEJS_ICU_NONE/g' feeds/packages/lang/node/Makefile

## Important Patches
# OpenSSL
wget -P package/libs/openssl/patches/ https://github.com/openssl/openssl/pull/11895.patch
wget -P package/libs/openssl/patches/ https://github.com/openssl/openssl/pull/14578.patch
wget -P package/libs/openssl/patches/ https://github.com/openssl/openssl/pull/16575.patch
# ARM64: Add CPU model name in proc cpuinfo
wget -P target/linux/generic/hack-5.4/ https://github.com/immortalwrt/immortalwrt/raw/openwrt-21.02/target/linux/generic/hack-5.4/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch
# Patch dnsmasq
patch -p1 < ../PATCH/new/package/dnsmasq-add-filter-aaaa-option.patch
patch -p1 < ../PATCH/new/package/luci-add-filter-aaaa-option.patch
cp -f ../PATCH/new/package/900-add-filter-aaaa-option.patch ./package/network/services/dnsmasq/patches/900-add-filter-aaaa-option.patch
# Patch kernel to fix fullcone conflict
wget -P target/linux/generic/hack-5.4 https://github.com/immortalwrt/immortalwrt/raw/openwrt-21.02/target/linux/generic/hack-5.4/952-net-conntrack-events-support-multiple-registrant.patch
# Patch firewall to enable fullcone
mkdir package/network/config/firewall/patches
wget -P package/network/config/firewall/patches/ https://github.com/immortalwrt/immortalwrt/raw/master/package/network/config/firewall/patches/fullconenat.patch
wget -qO- https://github.com/msylgj/R2S-R4S-OpenWrt/raw/21.02/PATCHES/001-fix-firewall-flock.patch | patch -p1
# Patch LuCI to add fullcone button
patch -p1 < ../PATCH/new/package/luci-app-firewall_add_fullcone.patch
# FullCone modules
cp -rf ../PATCH/duplicate/fullconenat ./package/network/fullconenat

## Extra Packages
# AutoCore
cp -rf ../PATCH/duplicate/autocore ./package/utils/autocore
rm -rf ./feeds/packages/utils/coremark
svn export https://github.com/immortalwrt/packages/trunk/utils/coremark feeds/packages/utils/coremark
# Autoreboot
svn export https://github.com/immortalwrt/luci/branches/openwrt-21.02/applications/luci-app-autoreboot feeds/luci/applications/luci-app-autoreboot
ln -sf ../../../feeds/luci/applications/luci-app-autoreboot ./package/feeds/luci/luci-app-autoreboot
# Ram-free
svn export https://github.com/immortalwrt/luci/branches/openwrt-21.02/applications/luci-app-ramfree feeds/luci/applications/luci-app-ramfree
ln -sf ../../../feeds/luci/applications/luci-app-ramfree ./package/feeds/luci/luci-app-ramfree

# Golang toolchain
rm -rf feeds/packages/lang/golang
svn co https://github.com/openwrt/packages/trunk/lang/golang feeds/packages/lang/golang

# ShadowsocksR Plus+
svn co https://github.com/fw876/helloworld/trunk/luci-app-ssr-plus ./package/new/luci-app-ssr-plus
rm -rf ./feeds/packages/net/shadowsocks-libev
rm -rf ./feeds/packages/net/xray-core
rm -rf ./feeds/packages/net/kcptun

svn co https://github.com/coolsnowwolf/packages/trunk/net/shadowsocks-libev ./package/new/shadowsocks-libev
svn co https://github.com/immortalwrt/packages/trunk/net/kcptun ./feeds/packages/net/kcptun
ln -sf ../../../feeds/packages/net/kcptun ./package/feeds/packages/kcptun

svn co https://github.com/fw876/helloworld/trunk/chinadns-ng ./package/new/chinadns-ng
svn co https://github.com/fw876/helloworld/trunk/dns2socks ./package/new/dns2socks
svn co https://github.com/fw876/helloworld/trunk/dns2tcp ./package/new/dns2tcp
svn co https://github.com/fw876/helloworld/trunk/gn ./package/new/gn
svn co https://github.com/fw876/helloworld/trunk/hysteria ./package/new/hysteria
svn co https://github.com/fw876/helloworld/trunk/ipt2socks ./package/new/ipt2socks
svn co https://github.com/fw876/helloworld/trunk/lua-neturl ./package/new/lua-neturl
svn co https://github.com/fw876/helloworld/trunk/microsocks ./package/new/microsocks
svn co https://github.com/fw876/helloworld/trunk/naiveproxy ./package/new/naiveproxy
svn co https://github.com/fw876/helloworld/trunk/redsocks2 ./package/new/redsocks2
svn co https://github.com/fw876/helloworld/trunk/shadowsocks-rust ./package/new/shadowsocks-rust
svn co https://github.com/fw876/helloworld/trunk/shadowsocksr-libev ./package/new/shadowsocksr-libev
svn co https://github.com/fw876/helloworld/trunk/simple-obfs ./package/new/simple-obfs
svn co https://github.com/fw876/helloworld/trunk/tcping ./package/new/tcping
svn co https://github.com/fw876/helloworld/trunk/trojan ./package/new/trojan
svn co https://github.com/fw876/helloworld/trunk/v2ray-core ./package/new/v2ray-core
svn co https://github.com/fw876/helloworld/trunk/v2ray-plugin ./package/new/v2ray-plugin
svn co https://github.com/fw876/helloworld/trunk/xray-core ./package/new/xray-core

pushd package/new
    wget -qO - https://github.com/fw876/helloworld/commit/5bbf6e7.patch | patch -p1
popd
rm -rf ./package/new/luci-app-ssr-plus/po/zh_Hans
sed -i '/Clang.CN.CIDR/a\o:value("https://gh.404delivr.workers.dev/https://github.com/QiuSimons/Chnroute/raw/master/dist/chnroute/chnroute.txt", translate("QiuSimons/Chnroute"))' ./package/new/luci-app-ssr-plus/luasrc/model/cbi/shadowsocksr/advanced.lua

## Ending
# Lets Fuck
mkdir package/base-files/files/usr/bin
cp -f ../PATCH/new/script/fuck package/base-files/files/usr/bin/fuck
# Conntrack_Max
sed -i 's/16384/65535/g' package/kernel/linux/files/sysctl-nf-conntrack.conf
# Remove config
rm -rf .config
