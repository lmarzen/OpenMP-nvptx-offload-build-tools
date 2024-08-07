# OpenMP-nvptx-offload-build-tools
Build scripts for compiling gcc(12.2.1) and clang(18) with OpenMP offload support for Nvidia GPUs.

gcc and clang will be built then installed in $HOME/ompoffload/gcc/install and $HOME/ompoffload/clang/install respectively.

The working and install directories can be changed by editing the WORKING_DIR and INSTALL_DIR variables at the top of the scripts.

Note: Before running the gcc_build.sh check where your cuda toolkit is installed and update the CUDA variable near the top of the script.

The working directory is not removed by the script, but you can safely delete the working directory after the script completes. You may want to do this because the source code of GCC and Clang takes up gigabytes of space and is no longer needed after the binaries have been compiled.


# clang
Building Clang:

In the build_clang.sh it is important to indicate what architectures you want to compile for. This is indicated with the following flags...
```
-DCLANG_OPENMP_NVPTX_DEFAULT_ARCH=sm_75
-DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES=75
```
Here I used sm_75, but you will need to change this to you GPU architecture. If you are unsure of you gpu architecture here is a resource to that will help you out: https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards/.

Compile for GPU:
```
/home/user/ompoffload/clang/bin/clang input.c -fopenmp -fopenmp-targets=nvptx64
```
Replace '/home/user/ompoffload/clang/bin/clang' with path to where your binary is.

You may receive the following error...
```
/home/user/ompoffload/clang/bin/clang-linker-wrapper: error: 'ld' failed
clang-15: error: linker command failed with exit code 1 (use -v to see invocation)
```
This is fixed by adding an additional flag, -L/home/user/ompoffload/clang/lib.
```
/home/user/ompoffload/clang/bin/clang input.c -fopenmp -fopenmp-targets=nvptx64 -L/home/user/ompoffload/clang/lib
```
To avoid specifying these paths repetitevly add the following lines to the end of your `~/.bashrc`.
```
PATH=/home/user/ompoffload/clang/bin/clang/bin:$PATH
LD_LIBRARY_PATH=/home/user/ompoffload/clang/lib:$LD_LIBRARY_PATH
```
Then re-source your `.bashrc` with
```
source ~/.bashrc
```
Now you can compile as follows for GPU,
```
clang input.c -fopenmp -fopenmp-targets=nvptx64
```

Compile for CPU:
```
clang input.c -fopenmp
```

# gcc
Building GCC:

Before running the gcc_build.sh check where your cuda toolkit is installed and update the CUDA variable near the top of the script.

Compile for GPU:
```
export LD_LIBRARY_PATH=/home/user/ompoffload/gcc/lib64
/home/user/ompoffload/gcc/bin/gcc input.c -fopenmp
```

Compile for CPU:
```
/home/user/ompoffload/gcc/bin/gcc input.c -fopenmp
```

