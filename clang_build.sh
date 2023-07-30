#!/bin/sh
# Build Clang with support for OpenMP offloading to NVIDIA GPUs.

WORKING_DIR=$HOME/ompoffload/.clang
INSTALL_DIR=$HOME/ompoffload/clang

mkdir -p $WORKING_DIR
cd $WORKING_DIR

# find the latest clang releases here: https://github.com/llvm/llvm-project/releases
# latest clang-16 release of clang...
git clone -b release/16.x https://github.com/llvm/llvm-project.git
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
cmake -DLLVM_ENABLE_PROJECTS="clang;openmp" \
      -DLLVM_TARGETS_TO_BUILD="X86;NVPTX" \
      -DCMAKE_BUILD_TYPE=Release \
      -G "Unix Makefiles" \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
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
      -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
      -DCLANG_OPENMP_NVPTX_DEFAULT_ARCH=sm_75 \
      -DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES=75 \
      ../llvm
make -j$(nproc) || exit 1
make -j$(nproc) install || exit 1
cd ..

# clean working directory
cd ../../
rm -rf $WORKING_DIR
