#!/bin/sh
# Build Clang with support for OpenMP offloading to NVIDIA and AMD GPUs.

WORKING_DIR=$HOME/ompoffload/.llvm18
INSTALL_DIR=$HOME/ompoffload/llvm18

mkdir -p $WORKING_DIR
cd $WORKING_DIR

# find the latest clang releases here: https://github.com/llvm/llvm-project/releases
# latest clang-18 release of clang...
git clone -b release/18.x --depth 1 https://github.com/llvm/llvm-project.git
cd llvm-project

# specific release of clang
# wget https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-15.0.1.tar.gz
# tar -xvf llvmorg-15.0.1.tar.gz
# rm llvmorg-15.0.1.tar.gz
# cd llvm-project-llvmorg-15.0.1

# latest experimental version of clang...
# git clone https://github.com/llvm/llvm-project.git
# cd llvm-project

mkdir build
cd build
cmake -DLLVM_ENABLE_PROJECTS="clang;lld;openmp" \
      -DLLVM_TARGETS_TO_BUILD="host;AMDGPU;NVPTX" \
      -DCMAKE_BUILD_TYPE=Release \
      -G "Unix Makefiles" \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
      -DLIBOMPTARGET_DEVICE_ARCHITECTURES="all" \
      -DLIBOMPTARGET_ENABLE_DEBUG=0 \
      ../llvm
make -j$(nproc) || exit 1
cd ..

# recompile clang with the compiler we just built, 'bootstrapping'
mkdir build2
cd build2
CC=../build/bin/clang \
CXX=../build/bin/clang++ \
cmake -DLLVM_ENABLE_PROJECTS="clang;lld;openmp" \
      -DLLVM_TARGETS_TO_BUILD="host;AMDGPU;NVPTX" \
      -DCMAKE_BUILD_TYPE=Release \
      -G "Unix Makefiles" \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
      -DLIBOMPTARGET_DEVICE_ARCHITECTURES="all" \
      -DLIBOMPTARGET_ENABLE_DEBUG=0 \
      ../llvm
make -j$(nproc) || exit 1
make -j$(nproc) install || exit 1
cd ..

# clean working directory
cd ../../
#rm -rf $WORKING_DIR
