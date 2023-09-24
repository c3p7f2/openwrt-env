#!/bin/bash
set -uo pipefail

config=${config:-""}

export DEBIAN_FRONTEND=noninteractive
export TERM=linux
export FORCE_UNSAFE_CONFIGURE=1
export OPENWRT_PATH=/home/builder/openwrt
export WORK_PATH=/home/builder

# 定义一些颜色变量
ERROR='\033[0;31m'
INFO='\033[0;32m'
WARNING='\033[0;33m'
DEBUG='\033[0;34m'
NC='\033[0m' # No Color

# 定义一个输出内容的函数
output() {
    echo -e "${DEBUG}[OpenWrt-Build] [$(date +"%Y-%m-%d %H:%M:%S")]${NC} ${1}"
}

# 定义错误处理函数
handle_error() {
    output "${INFO} 脚本终止 ${NC}"
    # 可以在这里添加你想要执行的特定操作
    exit 1
}

# 设置错误处理函数为trap
trap 'handle_error' ERR

output "${INFO} 检查openwrt_upstream参数是否存在${NC}"
if [ -z "$openwrt_upstream" ]; then
    echo -e "${ERROR}Error: openwrt_upstream parameter is required.${NC}"
    exit 1
fi

output "${INFO} 检查openwrt_upstream_branch参数是否存在${NC}"
if [ -z "$openwrt_upstream_branch" ]; then
    echo -e "${ERROR}Error: openwrt_upstream_branch parameter is required.${NC}"
    exit 1
fi

sudo chown -R builder:builder $OPENWRT_PATH


if [ -d $OPENWRT_PATH/.git ]; then
    output "${WARNING} ${OPENWRT_PATH}目录已经存在，跳过clone代码 ${NC}"
    cd $OPENWRT_PATH

else
    output "${INFO} 克隆openwrt源码仓库${NC}"

    
    cd $OPENWRT_PATH
    git init
    git remote add origin $openwrt_upstream
    git fetch
    git checkout $openwrt_upstream_branch -f

fi

# 使用已缓存工具链的代码以加速编译流程
###

output "${WARNING} 进入openwrt目录${NC}"

git pull

output "${INFO} 添加更多包${NC}"
$WORK_PATH/add-package.sh

output "${INFO} 正在更新并安装feeds${NC}"
./scripts/feeds update -a && ./scripts/feeds install -a

if [ -f "$WORK_PATH/.config" ]; then
    # 如果在容器内已经存在挂载的配置文件，则使用挂载的配置文件
    output "${INFO} 检测到已挂载的配置文件，直接使用该配置文件 ${NC}"
    cp $WORK_PATH/.config $OPENWRT_PATH/

else
    if [ -z "$config" ]; then
        # 如果没有config参数，根据默认机型生成配置
        output "${ERROR} config 参数未提供 (没有提供在线配置/本地配置，终止) ${NC}"
        exit 1
    else
        output "${WARNING} 尝试在线下载配置文件 ${NC}"
        # 使用curl命令尝试访问config参数
        mkdir -p /tmp
        curl -L --output /dev/null --silent --head --fail "$config"

        # 判断curl命令的返回值
        if [ $? -eq 0 ]; then
            # 如果返回值为0，说明config参数是一个有效的链接，下载配置文件到挂载的路径
            wget "$config" -O $OPENWRT_PATH/.config
        else
            # 如果返回值不为0，说明config参数不是一个有效的链接
            cp $config $OPENWRT_PATH/.config
        fi
    fi
fi

#chmod -R 777 $OPENWRT_PATH
make defconfig

output "${INFO} 下载配置依赖包${NC}"
make download -j8

output "${WARNING} 开始编译${NC}"
make -j$(($(nproc) + 1)) || make -j1 V=s

# 将编译好的固件复制到容器的根目录
output "${INFO} 编译结束${NC}"
