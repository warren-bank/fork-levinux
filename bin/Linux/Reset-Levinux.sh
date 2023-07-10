#!/usr/bin/env bash
set +e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

QEMU_DIR="${DIR}/../../QEMU"
SAVE_DIR="${DIR}/../../backup"

TIMESTAMP=$(date '+%Y-%m-%d-T%H-%M-%S')

cd "$QEMU_DIR"

mv 'home.qcow' "${SAVE_DIR}/home.${TIMESTAMP}.qcow"
rm 'opt.qcow'
rm 'tce.qcow'

cp 'home-fresh.qcow' 'home.qcow'
cp 'opt-fresh.qcow' 'opt.qcow'
cp 'tce-fresh.qcow' 'tce.qcow'

rm 'stderr.txt'
rm 'stdout.txt'
rm '*conflicted*'
rm "${DIR}/*ErrorLog*"
