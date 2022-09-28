#!/bin/sh
# Build GCC with support for OpenMP offloading to NVIDIA GPUs.

work_dir=$HOME/offload/gcc/work
install_dir=$HOME/offload/gcc/install

# Location of the installed CUDA toolkit
cuda=/opt/cuda

# build assembler and linking tools
mkdir -p $work_dir
cd $work_dir
git clone https://github.com/MentorEmbedded/nvptx-tools
cd nvptx-tools
./configure \
    --with-cuda-driver-include=$cuda/include \
    --with-cuda-driver-lib=$cuda/lib64 \
    --prefix=$install_dir
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
    --target=nvptx-none --with-build-time-tools=$install_dir/nvptx-none/bin \
    --enable-as-accelerator-for=$target \
    --disable-sjlj-exceptions \
    --enable-newlib-io-long-long \
    --enable-languages="c,c++,fortran,lto" \
    --prefix=$install_dir
make -j$(nproc) || exit 1
make -j$(nproc) install || exit 1
cd ..

# build host GCC
mkdir build-host-gcc
cd  build-host-gcc
../gcc/configure \
    --enable-offload-targets=nvptx-none \
    --with-cuda-driver-include=$cuda/include \
    --with-cuda-driver-lib=$cuda/lib64 \
    --disable-bootstrap \
    --disable-multilib \
    --enable-languages="c,c++,fortran,lto" \
    --prefix=$install_dir
make -j$(nproc) || exit 1
make -j$(nproc) install || exit 1
cd ..

# clean working directory
cd ..
rm -rf work