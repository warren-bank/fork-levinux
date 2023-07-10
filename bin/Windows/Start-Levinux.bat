@echo off

set QEMU_DIR=%~dp0..\..\QEMU
set TFTP_DIR=%~dp0..\..\customize

cd /D "%QEMU_DIR%"

start "Levinux" qemu.exe ^
-kernel vmlinuz ^
-initrd core.gz ^
-hda home.qcow ^
-hdb opt.qcow ^
-hdc tce.qcow ^
-tftp "%TFTP_DIR%" ^
-redir tcp:2222::22 ^
-redir tcp:8080::80 ^
-append "quiet noautologin loglevel=3 home=sda1 opt=sdb1 tce=sdc1"
