# openwrt-env

一键编译，专注于固件本身。

[![Docker Build](https://github.com/c3p7f2/openwrt-env/actions/workflows/docker-build.yml/badge.svg)](https://github.com/c3p7f2/openwrt-env/actions/workflows/docker-build.yml)

本地构建

```
docker build -t openwrt .
docker run -it -v $(pwd)/openwrt:/openwrt \
-e config=/path/to/your/config *OR* https://a.b.com/config openwrt \
-e openwrt_upstream=https://github.com/coolsnowwolf/lede

二次编译重复运行docker run... 命令即可

```

在线拉取镜像编译

```
// 使用dockerhub上的镜像

docker run -it -v $(pwd)/openwrt:/openwrt \
-e config=/path/to/your/config *OR* https://a.b.com/config shashiikora/build-openwrt-env:latest \
-e openwrt_upstream=https://github.com/coolsnowwolf/lede
```
