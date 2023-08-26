#!/bin/bash

# 检查openwrt_upstream参数是否存在
if [ -z "$openwrt_upstream" ]; then
    echo "Error: openwrt_upstream parameter is required."
    exit 1
fi

# 检查config参数是否存在
if [ -z "$config" ]; then
    echo "Error: config parameter is required."
    exit 1
fi

# 检查配置文件是否存在
if [ ! -f "$config" ]; then
    echo "Error: config file $config does not exist."
    exit 1
fi

# 使用curl命令尝试访问config参数
curl --output /dev/null --silent --head --fail "$config"

# 判断curl命令的返回值
if [ $? -eq 0 ]; then
    # 如果返回值为0，说明config参数是一个有效的链接，下载配置文件到/tmp/config
    wget "$config" -O /tmp/config
else
    # 如果返回值不为0，说明config参数不是一个有效的链接，直接使用它作为配置文件运行你的程序
    cp $config /tmp/config
fi

# 执行后面的命令
exec "$@"
