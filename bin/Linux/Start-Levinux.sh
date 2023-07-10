#!/usr/bin/env bash

if command -v resize >/dev/null; then
	resize -s 25 80 >/dev/null
else
	echo "Resize is not installed.  Levinux is best used in a 25x80 terminal." 2>&1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

QEMU_DIR="${DIR}/../../QEMU"
TFTP_DIR="${DIR}/../../customize"

cd "$QEMU_DIR"

./qemu-system-i386 -curses \
-kernel vmlinuz \
-initrd core.gz \
-L ./ \
-hda home.qcow \
-hdb opt.qcow \
-hdc tce.qcow \
-tftp "$TFTP_DIR" \
-redir tcp:2222::22 \
-redir tcp:8080::80 \
-append "quiet noautologin loglevel=3 home=sda1 opt=sdb1 tce=sdc1" 
