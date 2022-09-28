#!/bin/sh
# Build Clang with support for OpenMP offloading to NVIDIA GPUs.

install_dir=$HOME/offload/clang/install

# find the latest clang releases here: https://github.com/llvm/llvm-project/releases
# latest clang-15 release of clang...
wget https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-15.0.1.tar.gz
tar -xvf llvmorg-15.0.1.tar.gz
rm llvmorg-15.0.1.tar.gz
# latest experimental version of clang...
# git clone https://github.com/llvm/llvm-project.git

cd llvm-project-llvmorg-15.0.1
mkdir build
cd build
cmake -DLLVM_ENABLE_PROJECTS="clang;openmp" \
      -DLLVM_TARGETS_TO_BUILD="X86;NVPTX" \
      -DCMAKE_BUILD_TYPE=Release \
      -G "Unix Makefiles" \
      -DCMAKE_INSTALL_PREFIX=$install_dir \
      -DCLANG_OPENMP_NVPTX_DEFAULT_ARCH=sm_75 \
	-DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES=75 \
      ../llvm
make -j$(nproc) || exit 1
cd ..

# recompile clang with the compiler we just built, 'bootstrapping'
mkdir build2
cd build2
CC=../build/bin/clang \
CXX=../build/bin/clang++ \
cmake -DLLVM_ENABLE_PROJECTS="clang;openmp" \
      -DLLVM_TARGETS_TO_BUILD="X86;NVPTX" \
      -DCMAKE_BUILD_TYPE=Release \
      -G "Unix Makefiles" \
      -DCMAKE_INSTALL_PREFIX=$install_dir \
      -DCLANG_OPENMP_NVPTX_DEFAULT_ARCH=sm_75 \
	-DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES=75 \
      ../llvm
make -j$(nproc) || exit 1
make -j$(nproc) install || exit 1
cd ..

# clean working directory
cd ..
rm -rf llvm-project-llvmorg-15.0.1