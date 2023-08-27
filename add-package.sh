#!/bin/sh

# 通用
grep -q "kenzo" feeds.conf.default || sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
grep -q "small" feeds.conf.default || sed -i '$a src-git small https://github.com/kenzok8/small' feeds.conf.default
grep -q "cdnspeedtest" feeds.conf.default || echo "src-git cdnspeedtest https://github.com/immortalwrt-collections/openwrt-cdnspeedtest.git" >>"feeds.conf.default"

# 零散小包
cd package

# [ -d "luci-app-cloudflarespeedtest" ] || git clone https://github.com/mingxiaoyu/luci-app-cloudflarespeedtest.git
# N1
[ -d "luci-app-amlogic" ] || svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic luci-app-amlogic