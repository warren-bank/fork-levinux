### Levinux - Extensible Micro Linux Emulator

#### This Customization

* branch: [`custom/tcl-16.02/socks5_wireguard`](https://github.com/warren-bank/fork-levinux/tree/custom/tcl-16.02/socks5_wireguard)
  - forked from branch: [`mainline`](https://github.com/warren-bank/fork-levinux/tree/mainline)
    * forked from branch: [`upstream`](https://github.com/warren-bank/fork-levinux/tree/upstream)
      - mirror of repo: [`levinux`](https://github.com/miklevin/levinux)
        * forked from commit: [`3250f3d`](https://github.com/miklevin/levinux/tree/3250f3dd282166ff22b919d30308751f5671d248)
        * published on date: `Dec 16, 2022`
* users:
  - `tc:tc`
* TCZ extensions:
  - [WireGuard](https://www.wireguard.com/) userspace tools
  - [OpenSSH](https://github.com/openssh/openssh-portable) SSH client and server
    * SSH server
      - port in guest: `22`
      - port on host: `2222`
      - command to connect with SSH client on host:
        ```bash
          ssh -p 2222 tc@localhost
          # password: tc
        ```
    * SOCKS5 server
      - port in guest: `1080`
      - port on host: `1080`
      - command to proxy HTTP request through VPN from host:
        ```bash
          url='http://ipecho.net/plain'
          proxy='socks5h://localhost:1080'
          curl --silent --proxy "$proxy" "$url"
        ```

- - - -

#### Components

* [QEMU PC emulator](https://www.qemu.org/) version 0.12.5 (32-bit)
* [Tiny Core Linux](http://tinycorelinux.net/) version 16.2
  - [TCZ extensions](http://distro.ibiblio.org/tinycorelinux/16.x/x86/tcz/)

#### Features

* micro
  - 35.0 MB zip file
  - 45.0 MB unpacked size on disk
* portable
  - runs from USB or _Dropbox_
  - no admin rights are required
  - includes _QEMU_ binaries for: Linux, MacOS, Windows

#### Usage

1. download a [snapshot of this branch](https://github.com/warren-bank/fork-levinux/archive/refs/heads/custom/tcl-16.02/socks5_wireguard.zip) from the github repo
2. unzip
   - to any directory of your choosing
   - on any drive
3. configure
   - [WireGuard](#wireguard-configuration)
   - [OpenSSH](#openssh-configuration)
4. run the shell script that is appropriate for your host operating system:
   - on: [Windows](./bin/Windows/Start-Levinux.bat)
   - on: [Linux](./bin/Linux/Start-Levinux.sh)
   - on: [MacOS](./bin/MacOS/Start-Levinux.sh)<br>
     or:
     * open the directory: `./bin/MacOS`
     * double-click: `Start-Levinux`

#### Factory Reset

1. run the shell script that is appropriate for your host operating system:
   - on: [Windows](./bin/Windows/Reset-Levinux.bat)
   - on: [Linux](./bin/Linux/Reset-Levinux.sh)
   - on: [MacOS](./bin/MacOS/Reset-Levinux.sh)<br>
     or:
     * open the directory: `./bin/MacOS`
     * double-click: `Reset-Levinux`

__notes__:

* [Factory Reset](#factory-reset) does not undo [WireGuard Configuration](#wireguard-configuration) or [OpenSSH Configuration](#openssh-configuration)

- - - -

#### WireGuard Configuration

###### _(required)_

* copy one or more WireGuard config files to the directory:<br>`./tftp/customize/WireGuard`
* add the filename of one or more WireGuard config file(s) to the list file:<br>`./tftp/customize/WireGuard/list.txt`

__example__:

```bash
  cd ./tftp/customize/WireGuard

  find *.conf >list.txt
```

__notes__:

* the WireGuard config files can have any filename
  - for clarity, the previous example assumed that these WireGuard config files have the filename extension: `.conf`
* only one WireGuard config file is used to establish a VPN connection
* when `list.txt` contains only a single filename
  - this specific WireGuard config file will be used
* when `list.txt` contains multiple filenames
  - only one filename will be randomly selected from the list
  - only this WireGuard config file will be used
* the WireGuard network interface is assigned the name: `tun0`

- - - -

#### OpenSSH Configuration

###### _(optional, for advanced users only)_

__files__:

* [`ssh_config`](./tftp/foundation/extensions/openssh/config/ssh_config)
* [`sshd_config`](./tftp/foundation/extensions/openssh/config/sshd_config)

__notes__:

* both of these config files are identical to the _example_ config files that are included with OpenSSH
* changes made to these config files by a user must be saved before either:
  - 1st boot after download
  - 1st boot after [Factory Reset](#factory-reset)

__external references__:

* [`ssh_config`](https://man.freebsd.org/cgi/man.cgi?ssh_config)
* [`sshd_config`](https://man.freebsd.org/cgi/man.cgi?sshd_config)

- - - -

#### Upgrading the version of _Tiny Core Linux_

###### _(optional, for advanced users only)_

1. open a web browser to the _Tiny Core Linux_ [download page](http://distro.ibiblio.org/tinycorelinux/downloads.html)
   - navigate to the _Core x86 Release Files_
     * for example, [version 16.x](http://distro.ibiblio.org/tinycorelinux/16.x/x86/release/)
   - download the file: `Core-x.x.iso`
     * for example, [Core-16.2.iso](http://distro.ibiblio.org/tinycorelinux/16.x/x86/release/Core-16.2.iso) at 18.5 MB
2. open the .iso file
   - note: [7-Zip](https://www.7-zip.org/) works great
   - extract the files:
     * `/boot/core.gz`
     * `/boot/vmlinuz`
3. save these two files to the directory path: `./QEMU`
   - overwrite the existing files
