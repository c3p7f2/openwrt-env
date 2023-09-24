#!/bin/bash

# 通用
# grep -q "kenzo" feeds.conf.default || sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default

# 零散小包
cd package

## ProxyApps
[ -d "luci-app-openclash" ] || svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash luci-app-openclash

## N1 APP
[ -d "luci-app-amlogic" ] || svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic luci-app-amlogic

## Themes
