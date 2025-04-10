#!/bin/bash
set -e -x  # Exit immediately if any command fails

# Compile hvisor-tool
(
    export PATH=$PATH:$(pwd)/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/bin
    # mkdir rootfs/
    # sudo mount ./platform/aarch64/qemu-gicv3/image/virtdisk/rootfs1.ext4 rootfs
    # sudo ls -l rootfs/home/arm64
    # pwd
    # git clone https://github.com/CHonghaohao/linux_5.4.git
    # git clone https://github.com/syswonder/hvisor-tool.git
    # cd hvisor-tool
    # make all ARCH=arm64 LOG=LOG_WARN KDIR=../../linux_5.4
    # cd ..
    # sudo cp ./hvisor-tool/tools/hvisor ./rootfs/home/arm64/
    # sudo cp ./hvisor-tool/driver/hvisor.ko ./rootfs/home/arm64/
    # sudo cp ./
    # echo "Project directory is: $GITHUB_WORKSPACE"
    # sudo ls -l rootfs/home/arm64
    # sudo umount rootfs

    cd ./platform/aarch64/qemu-gicv3/image/virtdisk
    mkdir rootfs/
    sudo mount rootfs1.ext4 rootfs
    sudo ls -l rootfs/home/arm64
    pwd
    git clone https://github.com/CHonghaohao/linux_5.4.git
    git clone https://github.com/syswonder/hvisor-tool.git
    cd hvisor-tool
    ldd --version
    echo "rootfs pwd: $GITHUB_WORKSPACE/platform/aarch64/qemu-gicv3/image/virtdisk/rootfs/"
    # make all ARCH=arm64 LOG=LOG_INFO KDIR=../../linux_5.4 ROOT=$GITHUB_WORKSPACE/platform/aarch64/qemu-gicv3/image/virtdisk/rootfs/
    make all ARCH=arm64 LOG=LOG_INFO KDIR=../../linux_5.4 -L/opt/glibc-2.35/lib -I/opt/glibc-2.35/include
    cd ..
    echo "Project directory is: $GITHUB_WORKSPACE"
    sudo cp ./hvisor-tool/tools/hvisor ./rootfs/home/arm64/
    sudo cp ./hvisor-tool/driver/hvisor.ko ./rootfs/home/arm64/
    # sudo cp ../dts/zone1-linux.dtb ./rootfs/home/arm64/zone1-linux.dtb
    # sudo cp ../../configs/zone1-linux.json ./rootfs/home/arm64/linux2.json
    # sudo cp ../../configs/zone1-linux-virtio.json ./rootfs/home/arm64/virtio_cfg2.json.json
    
    # sudo cp -r ../../test/systemtest/testcase/* ./rootfs/home/arm64/test/testcase/
    # sudo cp ../../test/systemtest/textract_dmesg.sh ./rootfs/home/arm64/test/
    # sudo cp ../../test/systemtest/tresult.sh ./rootfs/home/arm64/test/

    # sudo cp ../../test/systemtest/linux2.sh ./rootfs/home/arm64/
    # sudo cp ../../test/systemtest/screen_linux2.sh ./rootfs/home/arm64/

    sudo ls -l rootfs/home/arm64
    sudo umount rootfs
    
)
# Subshell automatically returns to original directory after execution