#!/bin/bash
set -uo pipefail

config=${config:-""}

export DEBIAN_FRONTEND=noninteractive
export TERM=linux
export FORCE_UNSAFE_CONFIGURE=1

# 定义一些颜色变量
ERROR='\033[0;31m'
INFO='\033[0;32m'
WARNING='\033[0;33m'
DEBUG='\033[0;34m'
NC='\033[0m' # No Color

# 定义一个输出内容的函数
output() {
    echo -e "${DEBUG}[$(date +"%Y-%m-%d %H:%M:%S")]${NC} ${1}"
}

output "${INFO} 基础依赖安装${NC}"
apt-get update -qq && apt-get install -y -qq \
    wget curl rxvt-unicode

output "${INFO} 检查openwrt_upstream参数是否存在${NC}"
if [ -z "$openwrt_upstream" ]; then
    echo -e "${ERROR}Error: openwrt_upstream parameter is required.${NC}"
    exit 1
fi

output "${INFO} 安装编译依赖包${NC}"
apt-get update -qq && apt-get install -y -qq \
    ack antlr3 aria2 asciidoc autoconf automake autopoint binutils bison btrfs-progs build-essential bzip2 ca-certificates ccache cmake coreutils cpio curl device-tree-compiler fastjar flex g++-multilib gawk gcc-multilib gettext git git-core gperf gzip haveged help2man intltool jq libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev libreadline-dev libssl-dev libtool libz-dev lrzsz mkisofs msmtp nano ninja-build p7zip p7zip-full patch pigz pkgconf python2.7 python3 python3-pip python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion swig tar texinfo uglifyjs unzip upx upx-ucl vim wget xmlto xsltproc xxd xz-utils yasm zip zlib1g-dev zstd \
    aria2 clang clangd ecj lib32gcc-s1 libfuse-dev libncursesw5 \
    libpython3-dev lld lldb python3-ply re2c

if [ -d /openwrt ]; then
    output "${WARNING} /openwrt目录已经存在，跳过clone代码${NC}"

else
    output "${INFO} 克隆openwrt源码仓库${NC}"
    git clone --depth=1 $openwrt_upstream /openwrt
fi

# 使用已缓存工具链的代码以加速编译流程
###

output "${WARNING} 进入openwrt目录${NC}"
cd /openwrt
git pull

output "${INFO} 添加更多包${NC}"
/add-package.sh

output "${INFO} 正在更新并安装feeds${NC}"
./scripts/feeds update -a && ./scripts/feeds install -a

output "${INFO} 获取配置${NC}"
rm -f .config
if [ -z "$config" ]; then
    # 如果没有config参数，根据默认机型生成配置
    output "${WARNING} config参数不存在，使用自适应配置${NC}"
else
    # 如果有config参数，继续执行原来的代码
    # 使用curl命令尝试访问config参数
    mkdir -p /tmp
    curl -L --output /dev/null --silent --head --fail "$config"

    # 判断curl命令的返回值
    if [ $? -eq 0 ]; then
        # 如果返回值为0，说明config参数是一个有效的链接，下载配置文件
        wget "$config" -O .config
    else
        # 如果返回值不为0，说明config参数不是一个有效的链接
        cp $config .config
    fi
fi
make defconfig

output "${INFO} 下载配置依赖包${NC}"
make download -j8

output "${WARNING} 开始编译${NC}"
make -j$(($(nproc) + 1)) || make -j1 V=s

# 将编译好的固件复制到容器的根目录
output "${INFO} 编译结束${NC}"
