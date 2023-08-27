# openwrt-env

包含固件编译、发布、通知预备容器，专注于固件本身。

[![Docker Build](https://github.com/c3p7f2/openwrt-env/actions/workflows/docker-build.yml/badge.svg)](https://github.com/c3p7f2/openwrt-env/actions/workflows/docker-build.yml)

本地构建

```
docker build -t openwrt .
docker run -it -v $(pwd):/output \
-e config=/path/to/your/config *OR* https://a.b.com/config openwrt \
-e openwrt_upstream=https://github.com/coolsnowwolf/lede

二次编译重复运行docker run... 命令即可

添加更多插件：修改 add-package.sh
```

在线拉取镜像编译

```
//
```
