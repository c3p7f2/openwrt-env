# 使用ubuntu作为基础镜像
FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive

# 修改软件源
RUN  sed -i s@/archive.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list

RUN  apt-get update && apt-get install -y \
    wget curl rxvt-unicode sudo

RUN  apt-get update && apt-get install -y \
ack antlr3 aria2 asciidoc autoconf automake autopoint binutils bison btrfs-progs build-essential bzip2 ca-certificates ccache cmake coreutils cpio curl device-tree-compiler fastjar flex g++-multilib gawk gcc-multilib gettext git git-core gperf gzip haveged help2man intltool jq libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev libreadline-dev libssl-dev libtool libz-dev lrzsz mkisofs msmtp nano ninja-build p7zip p7zip-full patch pigz pkgconf python2.7 python3 python3-pip python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion swig tar texinfo uglifyjs unzip upx upx-ucl vim wget xmlto xsltproc xxd xz-utils yasm zip zlib1g-dev zstd \
aria2 clang clangd ecj lib32gcc-s1 libfuse-dev libncursesw5 \
libpython3-dev lld lldb python3-ply re2c 


# 创建一个普通用户
RUN useradd -ms /bin/bash builder
# 添加sudo权限
RUN usermod -aG sudo builder
RUN echo 'builder ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers


# 复制entrypoint脚本到容器中
COPY *.sh /home/builder/

RUN chown -R builder:builder /home/builder

USER builder
# 添加可执行权限
RUN chmod +x /home/builder/*.sh




# 定义entrypoint
ENTRYPOINT ["/home/builder/entrypoint.sh"]