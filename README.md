# Sandbox RootFS
This is the sandbox's rootfs used by [lyrio-judge](https://github.com/lyrio-dev/judge). It's based on Ubuntu 22.04 and contains compilers (and interpreters) below:

* GCC 12
* Clang 14 (from [LLVM](https://apt.llvm.org/))
* OpenJDK 17
* Kotlin (from [SDKMAN!](https://kotlinlang.org/docs/tutorials/command-line.html))
* Free Pascal 3
* Python 2.7
* Python 3.9
* Python 3.10
* Swift (from [Swift.org](https://swift.org/))
* Rust (from [Rustup](https://rustup.rs/))
* Go (from [PPA](https://launchpad.net/~longsleep/+archive/ubuntu/golang-backports))
* GHC 9.0.1 (from [PPA](https://launchpad.net/~hvr/+archive/ubuntu/ghc))
* C# (from [Mono](https://www.mono-project.com/download/stable/))
* F# (from [Mono](https://www.mono-project.com/download/stable/))

Each compiler (or interpreter) is available in `$PATH`. It also contains [`testlib.h`](https://github.com/MikeMirzayanov/testlib) in `/usr/include`.

You can download it from [release](https://github.com/lyrio-dev/sandbox-rootfs/releases) or bootstrap by yourself.

# Bootstrapping
You'll need:

* A Linux box with root privilege
* `arch-chroot` (usually in the package `arch-install-scripts`)
* `debootstrap` (some old version of Debian's `debootstrap` couldn't bootstrap Ubuntu 22.04)

First, clone this repo:

```bash
git clone git@github.com:lyrio-dev/sandbox-rootfs.git
cd sandbox-rootfs
```

Set the path to bootstrap rootfs. If there're anything inside it, it'll be `rm -rf`-ed. If the path doesn't exist, it'll be `mkdir -p`-ed.

```bash
export ROOTFS_PATH=/rootfs
```

If you're root, just run the `bootstrap.sh` script:

```bash
./bootstrap.sh
```

Or if you use `sudo`, remember to preserve the `ROOTFS_PATH` environment variable with `-E` option:

```bash
sudo -E ./bootstrap.sh
```
