#!/bin/bash
set -e  # Exit immediately if any command fails

# Compile hvisor-tool
(
    cd ./platform/aarch64/qemu-gicv3/image/virtdisk
    mkdir rootfs/
    sudo mount rootfs1.ext4 rootfs
    sudo ls -ld rootfs/home/arm64
    pwd
    git clone https://github.com/CHonghaohao/linux_5.4.git
    git clone https://github.com/syswonder/hvisor-tool.git
    cd hvisor-tool
    make all ARCH=arm64 LOG=LOG_WARN KDIR=../../linux_5.4
    sudo cp ./tools/hvisor ../rootfs/home/arm64/
    sudo cp ./driver/hvisor.ko ../rootfs/home/arm64/
    cd ..
    sudo umount rootfs
    
)
# Subshell automatically returns to original directory after execution