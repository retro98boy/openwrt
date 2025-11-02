# docker buildx build -t retro98boy/openwrt-dev:latest .

FROM ubuntu:jammy

ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/usr/bin/bash", "-c"]

# 安装语系、时区、sudo等基础包
RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
 && apt update \
 && apt upgrade -y \
 && apt install -y locales tzdata sudo

# 设置时区和语系
RUN if [ -e /etc/localtime ]; then rm /etc/localtime; fi; ln -svf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
 && echo -e 'en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8' >> /etc/locale.gen \
 && locale-gen \
 && echo 'LANG=en_US.UTF-8' > /etc/locale.conf
ENV LANG=en_US.UTF-8

# 设置用户
RUN groupadd -g 1000 ubuntu \
 && useradd -m -s /bin/bash -u 1000 -g 1000 ubuntu \
 && usermod -aG sudo ubuntu \
 && passwd -d ubuntu \
 && echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
 && echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# 安装构建工具
# https://openwrt.org/docs/guide-developer/toolchain/install-buildsystem
# python3-pyelftools python3-dev zstd不在官方文档中，但需要
RUN apt install -y build-essential clang flex bison g++ gawk \
gcc-multilib g++-multilib gettext git libncurses-dev libssl-dev \
python3-distutils python3-setuptools python3-pyelftools python3-dev rsync swig unzip zlib1g-dev file wget zstd

# 清理
RUN apt autopurge -y && apt autoclean

RUN mkdir -p /workspace && chown ubuntu /workspace

WORKDIR /workspace
USER ubuntu
