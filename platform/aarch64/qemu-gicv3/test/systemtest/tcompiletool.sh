#!/bin/bash
set -e  # Exit immediately if any command fails

# Compile hvisor-tool
(
    cd ./platform/aarch64/qemu-gicv3/image/virtdisk
    mkdir rootfs/
    sudo mount rootfs1.ext4 rootfs
    echo "this is test" >> test.txt
    sudo cp test.txt rootfs/home/arm64
    sudo ls -ld rootfs
    pwd
    git clone https://github.com/syswonder/hvisor-tool.git
    cd hvisor-tool
    sudo make all ARCH=arm64 LOG=LOG_WARN KDIR=../../rootfs/home/arm64/linux_5.4
    cp ./tools/hvisor ../rootfs/home/arm64/linux_5.4
    cp ./driver/hvisor.ko ../rootfs/home/arm64/linux_5.4
    cd ..
    sudo umount rootfs
    
)
# Subshell automatically returns to original directory after execution