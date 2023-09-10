# openwrt-env

用 Docker 一键编译 OpenWrt，专注于固件本身。

本地构建

```
docker build -t build-openwrt-env .
docker run -i -v $(pwd)/openwrt:/openwrt \
-e config=/path/to/your/config *OR* https://a.b.com/config \
-e openwrt_upstream=https://github.com/coolsnowwolf/lede \
build-openwrt-env

二次编译重复运行docker run... 命令即可

```

在线拉取镜像编译

```
// 使用dockerhub上的镜像

docker run -i -v $(pwd)/openwrt:/openwrt \
-e config=/path/to/your/config *OR* https://a.b.com/config \
-e openwrt_upstream=https://github.com/coolsnowwolf/lede \
shashiikora/build-openwrt-env:latest
```
