#!/bin/bash
set -e  # Exit immediately if any command fails

# Compile hvisor-tool
(
    cd ./platform/aarch64/qemu-gicv3/image/virtdisk
    mkdir rootfs/
    sudo mount rootfs1.ext4 rootfs
    sudo cd rootfs/home/arm64/
    pwd
    git clone https://github.com/syswonder/hvisor-tool.git
    cd hvisor-tool
    make all ARCH=arm64 LOG=LOG_WARN KDIR=/home/chh/workspaces/linux_5.4
    cp ./tools/hvisor ../
    cp ./driver/hvisor.ko ../
    sudo umount rootfs
    
)
# Subshell automatically returns to original directory after execution