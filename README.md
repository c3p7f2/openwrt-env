# openwrt-env

包含固件编译、发布、通知预备容器，专注于固件本身。

本地构建

```
docker build -t openwrt .
docker run --rm -it -v $(pwd):/output \
-e config=/path/to/your/config openwrt \
-e openwrt_upstream=https://github.com/coolsnowwolf/lede
```

在线拉取镜像编译

```
//
```
