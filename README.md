# OpenMP-nvptx-offload-build-tools
Build scripts for compiling gcc(12.2.1) and clang(15.0.1) with OpenMP offload support for Nvidia GPUs.

gcc and clang will be built then installed in $HOME/ompoffload/gcc/install and $HOME/ompoffload/clang/install respectively.

The working and install directories can be changed by editing the WORKING_DIR and INSTALL_DIR variables at the top of the scripts.

Note: Before running the gcc_build.sh check where your cuda toolkit is installed and update the CUDA variable near the top of the script.

The working directory is not removed by the script, but you can safely delete the working directory after the script completes. You may want to do this because the source code of GCC and Clang takes up gigabytes of space and is no longer needed after the binaries have been compiled.


# clang
Compile for GPU:
```
bash /home/user/ompoffload/clang/install/bin/clang input.c -fopenmp -fopenmp-targets=nvptx64 -L/home/luke/offload/clang/install/lib
```
Replace '/home/user/ompoffload/clang/install/bin/clang' with path to were your binary is.

You may receive the following error...
```
/home/user/ompoffload/clang/install/bin/clang-linker-wrapper: error: 'ld' failed
clang-15: error: linker command failed with exit code 1 (use -v to see invocation)
```
This is fixed by adding an additional flag, -L/home/user/ompoffload/clang/install/lib.
```
bash /home/user/ompoffload/bin/clang input.c -fopenmp -fopenmp-targets=nvptx64 -L/home/user/ompoffload/clang/install/lib
```

Compile for CPU:
```
bash /home/user/ompoffload/bin/clang input.c -fopenmp
```

# gcc
Compile for GPU:
```
export LD_LIBRARY_PATH=/home/user/ompoffload/gcc/install/lib64
bash /home/user/ompoffload/gcc/install/bin/gcc input.c -fopenmp
```

Compile for CPU:
```
bash /home/user/ompoffload/gcc/install/bin/gcc input.c -fopenmp
```

