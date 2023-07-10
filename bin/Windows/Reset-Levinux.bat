@echo off

set QEMU_DIR=%~dp0..\..\QEMU
set SAVE_DIR=%~dp0..\..\backup

set month=%date:~4,2%
set day=%date:~7,2%
set year=%date:~10,4%
set hour=%time:~0,2%
set min=%time:~3,2%
set sec=%time:~6,2%
set TIMESTAMP=%year%-%month%-%day%-T%hour%-%min%-%sec%

cd /D "%QEMU_DIR%"

move "home.qcow" "%SAVE_DIR%\home.%TIMESTAMP%.qcow"
del /F /Q "opt.qcow"
del /F /Q "tce.qcow"

copy "home-fresh.qcow" "home.qcow"
copy "opt-fresh.qcow" "opt.qcow"
copy "tce-fresh.qcow" "tce.qcow"

del /F /Q "stderr.txt"
del /F /Q "stdout.txt"
del /F /Q "*conflicted*"
del /F /Q "%~dp0.\*ErrorLog*"
