#!/bin/sh

# ================================================
# default Tiny Core Linux shell is: busybox ash
# ================================================

guest_dir_home='/home/tc'
guest_dir_wireguard="${guest_dir_home}/wireguard"
guest_dir_confcfg="${guest_dir_wireguard}/config"
guest_dir_tce='/mnt/sdc1/tce'
guest_dir_tcz="${guest_dir_tce}/optional"

conflist_fname='list.txt'
confcfg_fname='tun0.conf'

tftp_dir_customize='/customize'
tftp_dir_wireguard="${tftp_dir_customize}/WireGuard"
tftp_dir_foundation='/foundation'
tftp_dir_extensions="${tftp_dir_foundation}/extensions"

clean_fresh_partitions() {
  [ -e "${guest_dir_home}/.ash_history" ] && rm -f "${guest_dir_home}/.ash_history"
  [ -e '/root/.ash_history' ] && sudo rm -f '/root/.ash_history'
}

configure_user() {
  echo -e "tc\ntc" | passwd tc > /dev/null
  echo 'etc/passwd' >> '/opt/.filetool.lst'
  echo 'etc/shadow' >> '/opt/.filetool.lst'
}

# [async] run script from: 'bootlocal.sh'
install_extension_openssh() {
  tftp -g -l "${guest_dir_tcz}/gcc_libs.tcz" -r "${tftp_dir_extensions}/openssh/gcc_libs.tcz" 10.0.2.2
  tftp -g -l "${guest_dir_tcz}/libedit.tcz"  -r "${tftp_dir_extensions}/openssh/libedit.tcz"  10.0.2.2
  tftp -g -l "${guest_dir_tcz}/ncursesw.tcz" -r "${tftp_dir_extensions}/openssh/ncursesw.tcz" 10.0.2.2
  tftp -g -l "${guest_dir_tcz}/openssl.tcz"  -r "${tftp_dir_extensions}/openssh/openssl.tcz"  10.0.2.2
  tftp -g -l "${guest_dir_tcz}/openssh.tcz"  -r "${tftp_dir_extensions}/openssh/openssh.tcz"  10.0.2.2

  sudo -u tc tce-load -i gcc_libs > /dev/null
  sudo -u tc tce-load -i libedit  > /dev/null
  sudo -u tc tce-load -i ncursesw > /dev/null
  sudo -u tc tce-load -i openssl  > /dev/null
  sudo -u tc tce-load -i openssh  > /dev/null

  # server config
  tftp -g -l '/usr/local/etc/ssh/ssh_config'  -r "${tftp_dir_extensions}/openssh/config/ssh_config"  10.0.2.2
  tftp -g -l '/usr/local/etc/ssh/sshd_config' -r "${tftp_dir_extensions}/openssh/config/sshd_config" 10.0.2.2
  normalize_eol '/usr/local/etc/ssh/ssh_config'
  normalize_eol '/usr/local/etc/ssh/sshd_config'
  sudo touch '/usr/local/etc/ssh/ssh_host_dsa_key'
  sudo '/usr/local/bin/ssh-keygen' -A

  # tc user config
  ssh_dir="${guest_dir_home}/.ssh"
  [ -d "$ssh_dir" ] && rm -rf "$ssh_dir"
  mkdir "$ssh_dir"
  echo -n 'localhost ' > "${ssh_dir}/known_hosts"
  cat '/usr/local/etc/ssh/ssh_host_rsa_key.pub' >> "${ssh_dir}/known_hosts"
  '/usr/local/bin/ssh-keygen' -t rsa -b 1024 -f "${ssh_dir}/id_rsa" -q -N ''
  cp "${ssh_dir}/id_rsa.pub" "${ssh_dir}/authorized_keys"
  chown -R tc "$ssh_dir"

  echo 'gcc_libs.tcz' >> "${guest_dir_tce}/onboot.lst"
  echo 'libedit.tcz'  >> "${guest_dir_tce}/onboot.lst"
  echo 'ncursesw.tcz' >> "${guest_dir_tce}/onboot.lst"
  echo 'openssl.tcz'  >> "${guest_dir_tce}/onboot.lst"
  echo 'openssh.tcz'  >> "${guest_dir_tce}/onboot.lst"

  echo '/usr/local/etc/init.d/openssh start & > /dev/null' >> '/opt/bootlocal.sh'
  echo '(sleep 10 && sudo -u tc /usr/local/bin/ssh -f -N -D 0.0.0.0:1080 tc@localhost) &' >> '/opt/bootlocal.sh'
  echo '/usr/local/etc/ssh/' >> '/opt/.filetool.lst'
}

# [async] run script from: 'bootlocal.sh'
install_extension_wireguard() {
  install_extension_bash

  tftp -g -l "${guest_dir_tcz}/db.tcz"                              -r "${tftp_dir_extensions}/wireguard/db.tcz"                              10.0.2.2
  tftp -g -l "${guest_dir_tcz}/iproute2.tcz"                        -r "${tftp_dir_extensions}/wireguard/iproute2.tcz"                        10.0.2.2
  tftp -g -l "${guest_dir_tcz}/iptables.tcz"                        -r "${tftp_dir_extensions}/wireguard/iptables.tcz"                        10.0.2.2
  tftp -g -l "${guest_dir_tcz}/ipv6-netfilter-6.12.11-tinycore.tcz" -r "${tftp_dir_extensions}/wireguard/ipv6-netfilter-6.12.11-tinycore.tcz" 10.0.2.2
  tftp -g -l "${guest_dir_tcz}/openresolv.tcz"                      -r "${tftp_dir_extensions}/wireguard/openresolv.tcz"                      10.0.2.2
  tftp -g -l "${guest_dir_tcz}/wireguard-tools.tcz"                 -r "${tftp_dir_extensions}/wireguard/wireguard-tools.tcz"                 10.0.2.2

  sudo -u tc tce-load -i db                              > /dev/null
  sudo -u tc tce-load -i iproute2                        > /dev/null
  sudo -u tc tce-load -i iptables                        > /dev/null
  sudo -u tc tce-load -i ipv6-netfilter-6.12.11-tinycore > /dev/null
  sudo -u tc tce-load -i openresolv                      > /dev/null
  sudo -u tc tce-load -i wireguard-tools                 > /dev/null

  prepare_wireguard_config

  echo 'db.tcz'                              >> "${guest_dir_tce}/onboot.lst"
  echo 'iproute2.tcz'                        >> "${guest_dir_tce}/onboot.lst"
  echo 'iptables.tcz'                        >> "${guest_dir_tce}/onboot.lst"
  echo 'ipv6-netfilter-6.12.11-tinycore.tcz' >> "${guest_dir_tce}/onboot.lst"
  echo 'openresolv.tcz'                      >> "${guest_dir_tce}/onboot.lst"
  echo 'wireguard-tools.tcz'                 >> "${guest_dir_tce}/onboot.lst"
  echo "sudo wg-quick up '${guest_dir_confcfg}/${confcfg_fname}' >'${guest_dir_wireguard}/wg-quick.log' 2>&1" >> '/opt/bootlocal.sh'

  prepare_wireguard_scripts
}

install_extension_bash() {
  tftp -g -l "${guest_dir_tcz}/bash.tcz"     -r "${tftp_dir_extensions}/bash/bash.tcz"     10.0.2.2
  tftp -g -l "${guest_dir_tcz}/ncursesw.tcz" -r "${tftp_dir_extensions}/bash/ncursesw.tcz" 10.0.2.2
  tftp -g -l "${guest_dir_tcz}/readline.tcz" -r "${tftp_dir_extensions}/bash/readline.tcz" 10.0.2.2

  sudo -u tc tce-load -i bash     > /dev/null
  sudo -u tc tce-load -i ncursesw > /dev/null
  sudo -u tc tce-load -i readline > /dev/null

  echo 'bash.tcz'     >> "${guest_dir_tce}/onboot.lst"
  echo 'ncursesw.tcz' >> "${guest_dir_tce}/onboot.lst"
  echo 'readline.tcz' >> "${guest_dir_tce}/onboot.lst"
}

normalize_eol() {
  fpath="$1"

  sudo sed -i 's/\r//' "$fpath"
}

prepare_script() {
  fpath="$1"

  normalize_eol  "$fpath"
  sudo chown tc  "$fpath"
  sudo chmod a+x "$fpath"
}

# [async] run script from: 'bootlocal.sh'
prepare_wireguard_config() {
  [ -d "$guest_dir_wireguard" ] || mkdir "$guest_dir_wireguard"
  tftp -g -l "${guest_dir_wireguard}/prepare_wireguard_config.sh" -r "${tftp_dir_extensions}/wireguard/config/prepare_wireguard_config.sh" 10.0.2.2
  tftp -g -l "${guest_dir_wireguard}/select_random_line_in_file"  -r "${tftp_dir_extensions}/wireguard/config/select_random_line_in_file"  10.0.2.2
  prepare_script "${guest_dir_wireguard}/prepare_wireguard_config.sh"
  prepare_script "${guest_dir_wireguard}/select_random_line_in_file"

  echo "'${guest_dir_wireguard}/prepare_wireguard_config.sh' '${guest_dir_confcfg}' '${tftp_dir_wireguard}' '${conflist_fname}' '${confcfg_fname}' '${guest_dir_wireguard}/select_random_line_in_file' > /dev/null" >> '/opt/bootlocal.sh'
}

# [async] run script from: 'bootlocal.sh'
prepare_wireguard_scripts() {
  # add helper script to PATH: print-my-ip
  #   - output:  prints public IP address to stdout
  #   - purpose: to verify that VPN is connected
  tftp -g -l "${guest_dir_home}/.local/bin/print-my-ip" -r "${tftp_dir_extensions}/wireguard/scripts/print-my-ip" 10.0.2.2
  prepare_script "${guest_dir_home}/.local/bin/print-my-ip"

  # after waiting 30 seconds for VPN to connect during startup, write the new public IP address to a text file in home directory
  echo "(sleep 30 && '${guest_dir_home}/.local/bin/print-my-ip' > '${guest_dir_home}/ip.txt') &" >> '/opt/bootlocal.sh'
}

# [async] run script from: 'bootlocal.sh'
prepare_boot_hook_async() {
  tftp -g -l '/etc/hook_boot_async.sh' -r "${tftp_dir_foundation}/hook_boot_async.sh" 10.0.2.2
  prepare_script '/etc/hook_boot_async.sh'

  echo '/etc/hook_boot_async.sh' >> '/opt/bootlocal.sh'
  echo 'etc/hook_boot_async.sh'  >> '/opt/.filetool.lst'
}

# [sync] run script from: 'bootsync.sh'
prepare_boot_hook_sync() {
  tftp -g -l '/etc/hook_boot_sync.sh' -r "${tftp_dir_foundation}/hook_boot_sync.sh" 10.0.2.2
  prepare_script '/etc/hook_boot_sync.sh'

  echo '/etc/hook_boot_sync.sh' >> '/opt/bootsync.sh'
  echo 'etc/hook_boot_sync.sh'  >> '/opt/.filetool.lst'
}

# invoke directly because 'bootsync.sh' is already running
run_boot_hook_sync() {
  '/etc/hook_boot_sync.sh'
}

prepare_boot_hooks() {
  prepare_boot_hook_async
  prepare_boot_hook_sync
}

prepare_login_hook() {
  tftp -g -l '/etc/hook_login.sh' -r "${tftp_dir_foundation}/hook_login.sh" 10.0.2.2
  prepare_script '/etc/hook_login.sh'

  echo '/etc/hook_login.sh' >> "${guest_dir_home}/.profile"
  echo 'etc/hook_login.sh'  >> '/opt/.filetool.lst'
}

prepare_recipe() {
  clean_fresh_partitions
  configure_user
  install_extension_openssh
  install_extension_wireguard
  prepare_boot_hooks
  prepare_login_hook

  filetool.sh -b

  run_boot_hook_sync
}

prepare_recipe
