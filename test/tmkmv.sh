# 将rootfs和Image移到相应的文件夹内
mkdir ./images/aarch64/kernel
mv ./Image ./images/aarch64/kernel/

mkdir ./images/aarch64/virtdisk
mv ./rootfs1.ext4 ./images/aarch64/virtdisk/