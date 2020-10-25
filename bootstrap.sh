#!/bin/bash

INSTALL_SCRIPT="install.sh"

cd "$(dirname "$0")"

set -e

if [[ "$UID" != "0" ]]; then
    echo This script must be run with root privileges.
    exit 1
fi

if ! arch-chroot -h >/dev/null 2>&1; then
    echo "You need arch-chroot to run this script."
    echo "Usually it's in the package "'"'"arch-install-scripts"'".'
    exit 1
fi

if ! debootstrap --version >/dev/null 2>&1; then
    echo "You need debootstrap to run this script."
    exit 1
fi

if [[ "$ROOTFS_PATH" == "" ]]; then
    echo "Please specify the path to put rootfs on with ROOTFS_PATH."
    exit 1
fi

if [[ "$MIRROR" == "" ]]; then
    MIRROR="https://mirrors.tuna.tsinghua.edu.cn/ubuntu"
fi

rm -rf "$ROOTFS_PATH"
mkdir -p "$ROOTFS_PATH"
debootstrap --components=main,universe focal "$ROOTFS_PATH" "$MIRROR"

cp "$INSTALL_SCRIPT" "$ROOTFS_PATH/root"
arch-chroot "$ROOTFS_PATH" "/root/$INSTALL_SCRIPT"
rm "$ROOTFS_PATH/root/$INSTALL_SCRIPT"
