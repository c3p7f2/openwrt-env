#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get install -y \
    wget curl
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

# 使用curl命令尝试访问config参数
mkdir -p /tmp
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

# 更新软件源并安装必要的依赖包
apt-get update && apt-get install -y \
    ack antlr3 aria2 asciidoc autoconf automake autopoint binutils bison btrfs-progs build-essential bzip2 ca-certificates ccache cmake coreutils cpio curl device-tree-compiler fastjar flex g++-multilib gawk gcc-multilib gettext git git-core gperf gzip haveged help2man intltool jq libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev libreadline-dev libssl-dev libtool libz-dev lrzsz mkisofs msmtp nano ninja-build p7zip p7zip-full patch pigz pkgconf python2.7 python3 python3-pip python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion swig tar texinfo uglifyjs unzip upx upx-ucl vim wget xmlto xsltproc xxd xz-utils yasm zip zlib1g-dev zstd \
    aria2 clang clangd ecj lib32gcc-s1 libfuse-dev libncursesw5 \
    libpython3-dev lld lldb python3-ply re2c

# 克隆openwrt源码仓库
git clone $openwrt_upstream /openwrt

# 进入openwrt目录
cd /openwrt

# 更新并安装feeds
bash /add-package.sh && git pull
./scripts/feeds update -a && ./scripts/feeds install -a

# 编译openwrt固件
cp /tmp/config /openwrt/.config
echo -e "$(nproc) thread compile"
make diffconfig
make toolchain/compile -j$(nproc) || make toolchain/compile -j1 V=s

make target/compile -j$(nproc) IGNORE_ERRORS="m n" BUILD_LOG=1 ||
    yes n | make target/compile -j1 V=s IGNORE_ERRORS=1
make package/compile -j$(nproc) IGNORE_ERRORS=1 || make package/compile -j1 V=s IGNORE_ERRORS=1
make package/index

make package/install -j$(nproc) || make package/install -j1 V=s
make target/install -j$(nproc) || make target/install -j1 V=s
echo "status=success" >>$GITHUB_OUTPUT
make json_overview_image_info
make checksum

# 将编译好的固件复制到容器的根目录
mv bin/targets/*/*/* /bin-output
