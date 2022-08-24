#!/bin/bash -e

GCC_VERSION="12"
LLVM_VERSION="14"
OPENJDK_VERSION="17"
GHC_VERSION="9.0.1"

UBUNTU_CODENAME="$(source /etc/os-release && echo "$UBUNTU_CODENAME")"
UBUNTU_VERSION="$(source /etc/os-release && echo "$VERSION_ID")"

# Fix PATH environment variable
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Set Locale
sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
export LC_ALL=en_US.UTF-8
echo 'LC_ALL=en_US.UTF-8' > /etc/default/locale

# Create sandbox user and directories
useradd -r sandbox -d /sandbox -m
mkdir -p /sandbox/{binary,source,working}

# Add ubuntu-updates source
ORIGINAL_SOURCE=$(head -n 1 /etc/apt/sources.list)
sed "s/$UBUNTU_CODENAME/$UBUNTU_CODENAME-updates/" <<< "$ORIGINAL_SOURCE" >> /etc/apt/sources.list

# Install dependencies
apt-get update
apt-get dist-upgrade -y
apt-get install -y gnupg ca-certificates curl wget locales unzip zip git

# Key: LLVM repo
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
# Key: Python repo
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BA6932366A755776
# Key: Go repo
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys F6BC817356A3D45E
# Key: Haskell repo
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys FF3AEACEF6F88286
# Key: Mono repo
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF

# Add sources
echo "deb http://apt.llvm.org/$UBUNTU_CODENAME/ llvm-toolchain-$UBUNTU_CODENAME-$LLVM_VERSION main" > /etc/apt/sources.list.d/llvm.list
echo "deb http://ppa.launchpad.net/deadsnakes/ppa/ubuntu $UBUNTU_CODENAME main" > /etc/apt/sources.list.d/python.list
echo "deb http://ppa.launchpad.net/longsleep/golang-backports/ubuntu $UBUNTU_CODENAME main" >  /etc/apt/sources.list.d/go.list
echo "deb http://ppa.launchpad.net/hvr/ghc/ubuntu focal main" > /etc/apt/sources.list.d/haskell.list
echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" > /etc/apt/sources.list.d/mono.list

# Install some language support via APT
apt-get update
apt-get install -y g++-$GCC_VERSION-multilib \
                   gcc-$GCC_VERSION-multilib \
                   clang-$LLVM_VERSION \
                   libc++-$LLVM_VERSION-dev \
                   libc++abi-$LLVM_VERSION-dev \
                   openjdk-$OPENJDK_VERSION-jdk \
                   fpc \
                   python2.7 \
                   python3.9 \
                   python3.10 \
                   golang-go \
                   ghc-$GHC_VERSION \
                   mono-devel \
                   fsharp

# Install Rust via Rustup
su sandbox -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"

# Install Kotlin via SDKMAN!
su sandbox -c "curl -s https://get.sdkman.io | bash"
su sandbox -s /bin/bash -c "source ~/.sdkman/bin/sdkman-init.sh && sdk install kotlin"

# Install Swift
SWIFT_URL_QUOTED="$(curl https://www.swift.org/download/ --compressed | grep -P "\"([^\"]+ubuntu$UBUNTU_VERSION.tar.gz)\"" -o | head -n 1)"
SWIFT_URL="$(eval "echo $SWIFT_URL_QUOTED")"
wget -O - "$SWIFT_URL" | tar -xzf - -C /opt
mv /opt/swift* /opt/swift

# Create symlinks for compilers and interpreters with non-common names and locations
ln -s /usr/bin/g++-$GCC_VERSION /usr/local/bin/g++
ln -s /usr/bin/gcc-$GCC_VERSION /usr/local/bin/gcc
ln -s /usr/bin/clang-$LLVM_VERSION /usr/local/bin/clang
ln -s /usr/bin/clang++-$LLVM_VERSION /usr/local/bin/clang++
ln -s /sandbox/.sdkman/candidates/kotlin/current/bin/kotlin /usr/local/bin/kotlin
ln -s /sandbox/.sdkman/candidates/kotlin/current/bin/kotlinc /usr/local/bin/kotlinc
ln -s /sandbox/.cargo/bin/rustc /usr/local/bin/rustc
ln -s /opt/swift/usr/bin/swiftc /usr/local/bin/swiftc

# Create wrapper for GHC
cat > /usr/local/bin/ghc <<EOF
#!/bin/bash
for DIR in /opt/ghc/*/lib/ghc-*/*; do
    export LD_LIBRARY_PATH="\$LD_LIBRARY_PATH:\$DIR"
done
/opt/ghc/bin/ghc "\$@"
EOF
chmod +x /usr/local/bin/ghc

# Clean the APT cache
apt-get clean

# Install testlib
git clone https://github.com/lyrio-dev/testlib /tmp/testlib
cp /tmp/testlib/testlib.h /usr/include/
