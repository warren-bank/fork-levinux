### Levinux - Extensible Micro Linux Emulator

#### Components

* [QEMU PC emulator](https://www.qemu.org/) version 0.12.5 (32-bit)
* [Tiny Core Linux](http://tinycorelinux.net/) version 7.2
  - [TCZ extensions](http://distro.ibiblio.org/tinycorelinux/7.x/x86/tcz/)

#### Features

* micro
  - 17.5 MB zip file
  - 28.5 MB unpacked size on disk
* portable
  - runs from USB or _Dropbox_
  - no admin rights are required
  - includes _QEMU_ binaries for: Linux, MacOS, Windows

#### Default Configuration

* users:
  - `tc:foo`
* TCZ extensions:
  - [dropbear](https://github.com/mkj/dropbear) SSH server
    * port in guest: `22`
    * port on host: `2222`
    * command to connect with ssh client on host:
      ```bash
        ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 tc@localhost -p 2222
        # password: foo
      ```
  - [busybox-httpd](https://oldwiki.archive.openwrt.org/doc/howto/http.httpd) HTTP server
    * port in guest: `80`
    * port on host: `8080`
    * URL to browse the hosted website:
      ```text
        http://localhost:8080/
      ```

#### Usage

1. download a snapshot of the github repo
   - the [`upstream` branch](https://github.com/warren-bank/fork-levinux/archive/refs/heads/upstream.zip) hasn't been modified from the original (commit: [3250f3](https://github.com/miklevin/levinux/tree/3250f3dd282166ff22b919d30308751f5671d248))
   - the [`mainline` branch](https://github.com/warren-bank/fork-levinux/archive/refs/heads/mainline.zip) includes minor changes, and serves as the foundation for my personal customizations
2. unzip
   - to any directory of your choosing
   - on any drive
3. run the shell script that is appropriate for your host operating system:
   - on: [Windows](./bin/Windows/Start-Levinux.bat)
   - on: [Linux](./bin/Linux/Start-Levinux.sh)
   - on: [MacOS](./bin/MacOS/Start-Levinux.sh)<br>
     or:
     * open the directory: `./bin/MacOS`
     * double-click: `Start-Levinux`

#### OS-specific behavior

* on _Windows_:
  - a prompt may ask permission to run the app and unblock the firewall
* on _Linux, Ubuntu 14.04 Nautilus_:
  - Edit &gt; Preferences &gt; Behavior &gt; Executable Text Files &gt; "Ask Each Time"
* on _MacOS_:
  - may require you to right-click or Control-click and open

#### Factory Reset

1. run the shell script that is appropriate for your host operating system:
   - on: [Windows](./bin/Windows/Reset-Levinux.bat)
   - on: [Linux](./bin/Linux/Reset-Levinux.sh)
   - on: [MacOS](./bin/MacOS/Reset-Levinux.sh)<br>
     or:
     * open the directory: `./bin/MacOS`
     * double-click: `Reset-Levinux`

- - - -

#### Design

* virtual filesystem
  - [`home.qcow`](./QEMU/home.qcow)
    * mount points:
      - `/mnt/sda1`
      - `/home`
  - [`opt.qcow`](./QEMU/opt.qcow)
    * mount points:
      - `/mnt/sdb1`
      - `/opt`
  - [`tce.qcow`](./QEMU/tce.qcow)
    * mount points:
      - `/mnt/sdc1`
  - tree:
    ```text
      /mnt/
      |-- sda1/
      |   `-- home/
      |       `-- tc/
      |           |-- Python3.sh
      |           |-- Recipe.sh
      |           |-- drinkme.sh
      |           `-- htdocs/
      |               |-- favicon.ico
      |               |-- index.html
      |               `-- style.css
      |-- sdb1/
      |   `-- opt/
      |       |-- bootlocal.sh
      |       |-- bootsync.sh
      |       |-- shutdown.sh
      |       `-- tcemirror
      `-- sdc1/
          `-- tce/
              |-- mydata.tgz
              |-- onboot.lst
              |-- ondemand/
              `-- optional/
                  |-- busybox-httpd.tcz
                  |-- busybox-httpd.tcz.md5.txt
                  |-- dropbear.tcz
                  `-- dropbear.tcz.md5.txt
    ```
* script: `/opt/bootsync.sh`
  - code:
    ```bash
      #!/bin/sh
      /usr/bin/sethostname box
      sleep 2
      if [ ! -f /home/tc/Recipe.sh ]; then
        until tftp -g -l /home/tc/Recip.sh -r /Recipe.sh 10.0.2.2
        do
          sleep 2;
        done
        tr -d '\r' </home/tc/Recip.sh >/home/tc/Recipe.sh
        rm /home/tc/Recip.sh
        sh /home/tc/Recipe.sh
      fi
      /opt/bootlocal.sh &
    ```
  - purpose:
    * the `if/then` block is executed:
      - the first time Levinux is started after its install
      - the first time Levinux is started after a factory reset
    * it copies the `Recipe.sh` script to the virtual filesystem, and runs it
* script: [`/home/tc/Recipe.sh`](./customize/Recipe.sh)
  - purpose:
    * installs the required TCZ extensions
      - copies the following files to the virtual directory path: `/mnt/sdc1/tce/optional`
        * [`dropbear.tcz`](./customize/Ingredients/dropbear.tcz)
        * [`busybox-httpd.tcz`](./customize/Ingredients/busybox-httpd.tcz)
      - appends each of these filenames to the list: `/mnt/sdc1/tce/onboot.lst`
        * which causes them to be automatically loaded every time Levinux reboots
    * copies files for the required TCZ extensions
      - private encryption key for the SSH server (in both RSA and DSS formats)
    * copies files that pertain to the Levinux mission
      - static HTML files for the webserver
      - bash scripts that are intended for users to execute
      - verbose welcome messages
    * prepares for the installation of optional TCZ extensions
      - copies the following files to the virtual directory path: `/home/tc/.extras`
        * [`extras.lst`](./customize/Ingredients/extras.lst)
        * [`install_extras.sh`](./customize/Ingredients/install_extras.sh)
    * runs `install_extras.sh`
      - notes:
        * optional TCZ extensions are __NOT__ automatically loaded every time Levinux reboots
        * `install_extras.sh` does __NOT__ append each of these filenames to the list: `/mnt/sdc1/tce/onboot.lst`
        * the script: `/home/tc/.extras/install_extras.sh`
          - currently needs to be executed manually by the user after subsequent reboots
          - could be appended to the file: `/opt/bootlocal.sh`
            * this would run the script every time Levinux reboots
            * but, this would be inefficient and unnecessarily overwrite the optional TCZ extensions before loading them
            * although, a simple pre-check for file existence would fix that
            * and, it would continue to allow for..
              - additional TCZ extensions to be added at any time,<br>
                by editing the virtual filepath: `/home/tc/.extras/extras.lst`
              - subset groups of TCZ extensions to be stored as separate lists,<br>
                and any particular list to be made primary at runtime,<br>
                either by renaming or symbolically relinking
    * appends commands that need to run every time Levinux reboots to the file: `/opt/bootlocal.sh`
      - code:
        ```bash
          /etc/init.d/dropbear start
          /usr/local/httpd/sbin/httpd -p 80 -h /home/tc/htdocs -u tc:staff
        ```
      - notes:
        * `/opt/bootlocal.sh` is called by `/opt/bootsync.sh`,<br>
          immediately after `Recipe.sh` is conditionally initialized
    * adds the user: `tc`
      - sets its password to: `foo`
      - updates the file: `/opt/.filetool.lst`
        * appends the following virtual filepaths:
          - `/etc/passwd`
          - `/etc/shadow`
        * this causes the new user to persist across reboots
    * calls: `filetool.sh -b`
      - this calls [a feature](https://www.brianlinkletter.com/2014/02/persistent-configuration-changes-in-tinycore-linux/) of _Tiny Core Linux_
      - all files specified by `/opt/.filetool.lst` are backed up to the file: `/mnt/sdc1/tce/mydata.tgz`
      - these files will subsequently be restored every time Levinux reboots

- - - -

#### Customization

* TCZ extensions:
  1. [browse the list](http://distro.ibiblio.org/tinycorelinux/7.x/x86/tcz/) of available TCZ extensions
     - each TCZ extension has the filename extension: `.tcz`
     - each TCZ extension includes a list of its dependencies, which has the filename extension: `.tcz.dep`
  2. download all of the necessary `.tcz` files
     - save to the directory path: `./customize/Ingredients/Custom`
  3. update the list of extra TCZ extensions
     - edit the file: [`extras.lst`](./customize/Ingredients/extras.lst)
     - add the name of every new `.tcz` file, but exclude the filename extension: `.tcz`
     - notes:
       * these edits will only take effect after `Recipe.sh` runs
       * to update this list in an initialized instance of Levinux,<br>apply these edits to the file at the virtual filepath: `/home/tc/.extras/extras.lst`

#### Upgrading the version of _Tiny Core Linux_

1. open a web browser to the _Tiny Core Linux_ [download page](http://distro.ibiblio.org/tinycorelinux/downloads.html)
   - navigate to the _Core x86 Release Files_
     * for example, [version 7.x](http://distro.ibiblio.org/tinycorelinux/7.x/x86/release/)
   - download the file: `Core-x.x.iso`
     * for example, [Core-7.2.iso](http://distro.ibiblio.org/tinycorelinux/7.x/x86/release/Core-7.2.iso) at 10.6 MB
2. open the .iso file
   - note: [7-Zip](https://www.7-zip.org/) works great
   - extract the files:
     * `/boot/core.gz`
     * `/boot/vmlinuz`
3. save these two files to the directory path: `./QEMU`
   - overwrite the existing files
