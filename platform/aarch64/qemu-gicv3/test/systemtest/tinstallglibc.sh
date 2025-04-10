#!/bin/bash
set -e -x  # Exit immediately if any command fails

# Compile hvisor-tool
(
    wget http://ftp.gnu.org/gnu/libc/glibc-2.35.tar.gz
    tar -xzf glibc-2.35.tar.gz
    cd glibc-2.35
    mkdir build
    cd build
    ../configure --prefix=/opt/glibc-2.35
    make
    sudo make install
    
)
# Subshell automatically returns to original directory after execution