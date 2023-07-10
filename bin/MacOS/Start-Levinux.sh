#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

QEMU_DIR="${DIR}/../../QEMU"
TFTP_DIR="${DIR}/../../customize"

cd "$QEMU_DIR"

./i386-softmmu \
-kernel vmlinuz \
-initrd core.gz \
-hda home.qcow \
-hdb opt.qcow \
-hdc tce.qcow \
-tftp "$TFTP_DIR" \
-redir tcp:2222::22 \
-redir tcp:8080::80 \
-append "quiet noautologin loglevel=3 home=sda1 opt=sdb1 tce=sdc1"
