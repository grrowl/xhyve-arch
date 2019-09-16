#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

if [ -z "$1" ]; then
    echo "missing path to iso"
    exit 1
fi

if [ "$(whoami)" != "root" ]; then
    echo "missing sudo"
    exit 1
fi

archlabel=$(hdiutil imageinfo "$1" 2>/dev/null | grep 'partition-name:' | cut -d' ' -f2 | head -1)
storagegb=16
memgb=2
cpus=1
MB=$[1024*1024]
GB=$[1024*$MB]

#has to check if it exist do not override it or ... and has to do it once
dd if=/dev/zero of=storage.img bs=$[1*$GB] count=$storagegb

# cannot point to ~/Downloads/storage.img, or  ../ has to run this script outside???

xhyve \
    -A \
    -c "$cpus" \
    -m "${memgb}G" \
    -s 0,hostbridge \
    -s 2,virtio-net \
    -s "3,ahci-cd,$1" \
    -s 4,virtio-blk,storage.img \
    -s 31,lpc \
    -l com1,stdio \
    -f "kexec,boot/vmlinuz,boot/archiso.img,earlyprintk=serial console=ttyS0 archisobasedir=arch archisolabel=$archlabel"
