# Sandbox RootFS NG
This is the sandbox's rootfs used by [syzoj-ng-judge](https://github.com/syzoj/syzoj-ng-judge). It's based on Ubuntu 20.04 and contains compilers (and interpreters) below:

* GCC 10
* Clang 11 (from [LLVM](https://apt.llvm.org/))
* OpenJDK 11
* Kotlin (from [SDKMAN!](https://kotlinlang.org/docs/tutorials/command-line.html))
* Free Pascal 3
* Python 2.7 (from [PPA](https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa))
* Python 3.6
* Python 3.9 (from [PPA](https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa))
* Rust (from [Rustup](https://rustup.rs/))
* Go (from [PPA](https://launchpad.net/~longsleep/+archive/ubuntu/golang-backports))
* GHC (from [PPA](https://launchpad.net/~hvr/+archive/ubuntu/ghc))
* C# (from [Mono](https://www.mono-project.com/download/stable/))
* F# (from [Mono](https://www.mono-project.com/download/stable/))

Each compiler (or interpreter) is available in `$PATH`. It also contains [`testlib.h`](https://github.com/MikeMirzayanov/testlib) in `/usr/include`.

You can download it from [release](https://github.com/syzoj/sandbox-rootfs-ng/releases) or bootstrap by yourself.

# Bootstrapping
You'll need:

* A Linux box with root privilege
* `arch-chroot` (usually in the package `arch-install-scripts`)
* `debootstrap` (some old version of Debian's `debootstrap` couldn't bootstrap Ubuntu 20.04)

First, clone this repo:

```bash
git clone git@github.com:syzoj/sandbox-rootfs-ng.git
cd sandbox-rootfs-ng
```

Set the path to bootstrap rootfs. If there're anything inside it, it'll be `rm -rf`-ed. If the path doesn't exist, it'll be `mkdir -p`-ed.

```bash
export ROOTFS_PATH=/rootfs-ng
```

If you're root, just run the `bootstrap.sh` script:

```bash
./bootstrap.sh
```

Or if you use `sudo`, remember to preserve the `ROOTFS_PATH` environment variable with `-E` option:

```bash
sudo -E ./bootstrap.sh
```
