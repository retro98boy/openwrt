# 仓库作用

为自己持有的硬件移植OpenWrt，目前支持的设备：

- TIANNUO TN3399_V3

- SMART AM40

# 编译步骤

## 准备环境

推荐使用Ubuntu 22.04 PC来编译，安装工具：

```
sudo apt install -y build-essential clang flex bison g++ gawk \
gcc-multilib g++-multilib gettext git libncurses-dev libssl-dev \
python3-distutils python3-setuptools python3-pyelftools python3-dev rsync swig unzip zlib1g-dev file wget zstd
```

## 准备源码

```
git clone -b 24.10.0 https://github.com/retro98boy/openwrt.git
```

## 更新feeds

```
./scripts/feeds update -a
./scripts/feeds install -a
```

可以自行添加feeds源，或者往feeds目录下面添加零散软件包，添加完毕后再次执行脚本

## 编译

使用`make menuconfig`进入配置界面调整配置，然后：

```
# 根据配置提前下载需要的软件源码，如果跳过这步直接进行下一步，会变成一边下载一边编译
make download V=s -j$(nproc)
# 编译
make V=s -j$(nproc)
```
