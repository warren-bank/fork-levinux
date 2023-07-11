#!/bin/sh

# ================================================
# default Tiny Core Linux shell is: busybox ash
# ================================================

guest_dir_home='/home/tc'
guest_dir_openvpn="${guest_dir_home}/openvpn"
guest_dir_ovpncfg="${guest_dir_openvpn}/config"
guest_dir_tce='/mnt/sdc1/tce'
guest_dir_tcz="${guest_dir_tce}/optional"

ovpnlist_fname='list.txt'
ovpnauth_fname='auth.txt'
ovpncfg_fname='ovpn.conf'

tftp_dir_customize='/customize'
tftp_dir_openvpn="${tftp_dir_customize}/OpenVPN"
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
  tftp -g -l "${guest_dir_tcz}/ncurses.tcz" -r "${tftp_dir_extensions}/openssh/ncurses.tcz" 10.0.2.2
  tftp -g -l "${guest_dir_tcz}/openssl.tcz" -r "${tftp_dir_extensions}/openssh/openssl.tcz" 10.0.2.2
  tftp -g -l "${guest_dir_tcz}/libedit.tcz" -r "${tftp_dir_extensions}/openssh/libedit.tcz" 10.0.2.2
  tftp -g -l "${guest_dir_tcz}/openssh.tcz" -r "${tftp_dir_extensions}/openssh/openssh.tcz" 10.0.2.2

  sudo -u tc tce-load -i ncurses > /dev/null
  sudo -u tc tce-load -i openssl > /dev/null
  sudo -u tc tce-load -i libedit > /dev/null
  sudo -u tc tce-load -i openssh > /dev/null

  # server config
  sudo cp '/usr/local/etc/ssh/ssh_config.example' '/usr/local/etc/ssh/ssh_config'
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

  echo 'ncurses.tcz' >> "${guest_dir_tce}/onboot.lst"
  echo 'openssl.tcz' >> "${guest_dir_tce}/onboot.lst"
  echo 'libedit.tcz' >> "${guest_dir_tce}/onboot.lst"
  echo 'openssh.tcz' >> "${guest_dir_tce}/onboot.lst"

  echo '/usr/local/etc/init.d/openssh start & > /dev/null' >> '/opt/bootlocal.sh'
  echo '(sleep 10 && sudo -u tc /usr/local/bin/ssh -f -N -D 0.0.0.0:1080 tc@localhost) &' >> '/opt/bootlocal.sh'
  echo '/usr/local/etc/ssh/' >> '/opt/.filetool.lst'
}

# [async] run script from: 'bootlocal.sh'
install_extension_openvpn() {
  tftp -g -l "${guest_dir_tcz}/db.tcz"               -r "${tftp_dir_extensions}/openvpn/db.tcz"               10.0.2.2
  tftp -g -l "${guest_dir_tcz}/lzo.tcz"              -r "${tftp_dir_extensions}/openvpn/lzo.tcz"              10.0.2.2
  tftp -g -l "${guest_dir_tcz}/openssl.tcz"          -r "${tftp_dir_extensions}/openvpn/openssl.tcz"          10.0.2.2
  tftp -g -l "${guest_dir_tcz}/iproute2.tcz"         -r "${tftp_dir_extensions}/openvpn/iproute2.tcz"         10.0.2.2
  tftp -g -l "${guest_dir_tcz}/libpkcs11-helper.tcz" -r "${tftp_dir_extensions}/openvpn/libpkcs11-helper.tcz" 10.0.2.2
  tftp -g -l "${guest_dir_tcz}/openvpn.tcz"          -r "${tftp_dir_extensions}/openvpn/openvpn.tcz"          10.0.2.2

  sudo -u tc tce-load -i db               > /dev/null
  sudo -u tc tce-load -i lzo              > /dev/null
  sudo -u tc tce-load -i openssl          > /dev/null
  sudo -u tc tce-load -i iproute2         > /dev/null
  sudo -u tc tce-load -i libpkcs11-helper > /dev/null
  sudo -u tc tce-load -i openvpn          > /dev/null

  prepare_openvpn_config

  echo 'db.tcz'               >> "${guest_dir_tce}/onboot.lst"
  echo 'lzo.tcz'              >> "${guest_dir_tce}/onboot.lst"
  echo 'openssl.tcz'          >> "${guest_dir_tce}/onboot.lst"
  echo 'iproute2.tcz'         >> "${guest_dir_tce}/onboot.lst"
  echo 'libpkcs11-helper.tcz' >> "${guest_dir_tce}/onboot.lst"
  echo 'openvpn.tcz'          >> "${guest_dir_tce}/onboot.lst"
  echo "(cd '$guest_dir_ovpncfg' && openvpn --config '${guest_dir_ovpncfg}/${ovpncfg_fname}' --daemon --log '${guest_dir_openvpn}/log.txt' --verb 3)" >> '/opt/bootlocal.sh'

  # add helper script to PATH that pipes the public IP address to stdout
  fpath="${guest_dir_home}/.local/bin/ip"
  touch "$fpath"
  echo '#!/bin/sh' >> "$fpath"
  echo 'wget -q -O - "http://ipecho.net/plain"' >> "$fpath"
  chmod a+x "$fpath"

  # after waiting 30 seconds for VPN to connect during startup, write the new public IP address to a text file in home directory
  echo "(sleep 30 && '${fpath}' > '${guest_dir_home}/ip.txt') &" >> '/opt/bootlocal.sh'
}

prepare_bash_script() {
  fpath="$1"

  sudo sed -i 's/\r//' "$fpath"
  sudo chown tc        "$fpath"
  sudo chmod a+x       "$fpath"
}

# [async] run script from: 'bootlocal.sh'
prepare_openvpn_config() {
  [ -d "$guest_dir_openvpn" ] || mkdir "$guest_dir_openvpn"
  tftp -g -l "${guest_dir_openvpn}/prepare_openvpn_config.sh"  -r "${tftp_dir_extensions}/openvpn/config/prepare_openvpn_config.sh"  10.0.2.2
  tftp -g -l "${guest_dir_openvpn}/select_random_line_in_file" -r "${tftp_dir_extensions}/openvpn/config/select_random_line_in_file" 10.0.2.2
  tftp -g -l "${guest_dir_openvpn}/filter_openvpn_config.sh"   -r "${tftp_dir_extensions}/openvpn/config/filter_openvpn_config.sh"   10.0.2.2
  prepare_bash_script "${guest_dir_openvpn}/prepare_openvpn_config.sh"
  prepare_bash_script "${guest_dir_openvpn}/select_random_line_in_file"
  prepare_bash_script "${guest_dir_openvpn}/filter_openvpn_config.sh"

  echo "'${guest_dir_openvpn}/prepare_openvpn_config.sh' '${guest_dir_ovpncfg}' '${tftp_dir_openvpn}' '${ovpnlist_fname}' '${ovpnauth_fname}' '${ovpncfg_fname}' '${guest_dir_openvpn}/select_random_line_in_file' '${guest_dir_openvpn}/filter_openvpn_config.sh' > /dev/null" >> '/opt/bootlocal.sh'
}

# [async] run script from: 'bootlocal.sh'
prepare_boot_hook_async() {
  tftp -g -l '/etc/hook_boot_async.sh' -r "${tftp_dir_foundation}/hook_boot_async.sh" 10.0.2.2
  prepare_bash_script '/etc/hook_boot_async.sh'

  echo '/etc/hook_boot_async.sh' >> '/opt/bootlocal.sh'
  echo 'etc/hook_boot_async.sh'  >> '/opt/.filetool.lst'
}

# [sync] run script from: 'bootsync.sh'
prepare_boot_hook_sync() {
  tftp -g -l '/etc/hook_boot_sync.sh' -r "${tftp_dir_foundation}/hook_boot_sync.sh" 10.0.2.2
  prepare_bash_script '/etc/hook_boot_sync.sh'

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
  prepare_bash_script '/etc/hook_login.sh'

  echo '/etc/hook_login.sh' >> "${guest_dir_home}/.profile"
  echo 'etc/hook_login.sh'  >> '/opt/.filetool.lst'
}

prepare_recipe() {
  clean_fresh_partitions
  configure_user
  install_extension_openssh
  install_extension_openvpn
  prepare_boot_hooks
  prepare_login_hook

  filetool.sh -b

  run_boot_hook_sync
}

prepare_recipe
