# 使用ubuntu作为基础镜像
FROM ubuntu:latest

# 更新软件源并安装必要的依赖包
RUN apt-get update && apt-get install -y \
    ack antlr3 aria2 asciidoc autoconf automake autopoint binutils bison btrfs-progs build-essential bzip2 ca-certificates ccache cmake coreutils cpio curl device-tree-compiler fastjar flex g++-multilib gawk gcc-multilib gettext git git-core gperf gzip haveged help2man intltool jq libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev libreadline-dev libssl-dev libtool libz-dev lrzsz mkisofs msmtp nano ninja-build p7zip p7zip-full patch pigz pkgconf python2.7 python3 python3-pip python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion swig tar texinfo uglifyjs unzip upx upx-ucl vim wget xmlto xsltproc xxd xz-utils yasm zip zlib1g-dev zstd \
    aria2 clang clangd ecj lib32gcc-s1 libfuse-dev libncursesw5 \
    libpython3-dev lld lldb python3-ply re2c


# 克隆openwrt源码仓库
RUN git clone $openwrt_upstream

# 进入openwrt目录
WORKDIR /openwrt

# 更新并安装feeds
RUN ./scripts/feeds update -a && ./scripts/feeds install -a

# 编译openwrt固件
RUN cp /tmp/config /openwrt/.config && \
    make -j$(nproc)

# 将编译好的固件复制到容器的根目录
RUN cp bin/targets/*/*/*.bin /

# 复制entrypoint脚本到容器中
COPY entrypoint.sh /entrypoint.sh

# 添加可执行权限
RUN chmod +x /entrypoint.sh

# 定义entrypoint
ENTRYPOINT ["/entrypoint.sh"]