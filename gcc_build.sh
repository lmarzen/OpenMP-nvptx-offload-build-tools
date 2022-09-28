#!/bin/sh
# Build GCC with support for OpenMP offloading to NVIDIA GPUs.

WORKING_DIR=$HOME/ompoffload/gcc/work
INSTALL_DIR=$HOME/ompoffload/gcc/install

# location of the installed CUDA toolkit
CUDA=/opt/cuda

# build assembler and linking tools
mkdir -p $WORKING_DIR
cd $WORKING_DIR
git clone https://github.com/MentorEmbedded/nvptx-tools
cd nvptx-tools
./configure \
    --with-cuda-driver-include=$CUDA/include \
    --with-cuda-driver-lib=$CUDA/lib64 \
    --prefix=$INSTALL_DIR
make -j$(nproc) || exit 1
make -j$(nproc) install || exit 1
cd ..

# set up the GCC source tree
git clone git://sourceware.org/git/newlib-cygwin.git nvptx-newlib
# latest gcc-12 release of gcc...
git clone --branch releases/gcc-12 git://gcc.gnu.org/git/gcc.git gcc
# latest experimental version of gcc...
# git clone git://gcc.gnu.org/git/gcc.git gcc

cd gcc
contrib/download_prerequisites
ln -s ../nvptx-newlib/newlib newlib
cd ..
target=$(gcc/config.guess)

# build nvptx GCC
mkdir build-nvptx-gcc
cd build-nvptx-gcc
../gcc/configure \
    --target=nvptx-none --with-build-time-tools=$INSTALL_DIR/nvptx-none/bin \
    --enable-as-accelerator-for=$target \
    --disable-sjlj-exceptions \
    --enable-newlib-io-long-long \
    --enable-languages="c,c++,fortran,lto" \
    --prefix=$INSTALL_DIR
make -j$(nproc) || exit 1
make -j$(nproc) install || exit 1
cd ..

# build host GCC
mkdir build-host-gcc
cd  build-host-gcc
../gcc/configure \
    --enable-offload-targets=nvptx-none \
    --with-cuda-driver-include=$CUDA/include \
    --with-cuda-driver-lib=$CUDA/lib64 \
    --disable-bootstrap \
    --disable-multilib \
    --enable-languages="c,c++,fortran,lto" \
    --prefix=$INSTALL_DIR
make -j$(nproc) || exit 1
make -j$(nproc) install || exit 1
cd ..

# clean working directory
cd ..
rm -rf $WORKING_DIR