# openwrt-env

用 Docker 一键编译 OpenWrt，专注于固件本身。

本地构建

```
sudo docker build -t openwrt-build . && 

sudo docker run -it \ 
-v /home/neko/openwrt:/home/builder/openwrt \
-v /home/neko/openwrt-env/.config:/home/builder/.config \ #（可选：本地配置 优先度高）
-e openwrt_upstream=https://github.com/openwrt/openwrt \
-e openwrt_upstream_branch=openwrt-23.05 \
-e config=https://myconfig.com \ #（可选：在线配置URL 指定此项无需映射本地配置）
openwrt-build

```