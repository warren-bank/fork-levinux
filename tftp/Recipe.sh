#!/bin/sh

# ================================================
# default Tiny Core Linux shell is: busybox ash
# ================================================

guest_dir_home='/home/tc'
guest_dir_htdocs="${guest_dir_home}/htdocs"
guest_dir_install_scripts="${guest_dir_home}/install_scripts"
guest_dir_extras="${guest_dir_home}/.extras"
guest_dir_tce='/mnt/sdc1/tce'
guest_dir_tcz="${guest_dir_tce}/optional"

tftp_dir_customize='/customize'
tftp_dir_extras="${tftp_dir_customize}/extras"
tftp_dir_foundation='/foundation'
tftp_dir_extensions="${tftp_dir_foundation}/extensions"
tftp_dir_install_scripts="${tftp_dir_foundation}/install_scripts"

clean_fresh_partitions() {
  [ -e "${guest_dir_home}/.ash_history" ] && rm -f "${guest_dir_home}/.ash_history"
  [ -e '/root/.ash_history' ] && sudo rm -f '/root/.ash_history'
}

configure_user() {
  echo -e "tc\ntc" | passwd tc > /dev/null
  echo 'etc/passwd' >> '/opt/.filetool.lst'
  echo 'etc/shadow' >> '/opt/.filetool.lst'
}

install_extension_dropbear() {
  tftp -g -l "${guest_dir_tcz}/dropbear.tcz" -r "${tftp_dir_extensions}/dropbear/dropbear.tcz" 10.0.2.2

  sudo -u tc tce-load -i dropbear > /dev/null

  [ -d '/usr/local/etc/dropbear' ] || mkdir '/usr/local/etc/dropbear'
  tftp -g -l '/usr/local/etc/dropbear/dropbear_dss_host_key' -r "${tftp_dir_extensions}/dropbear/private_key/dropbear_dss_host_key" 10.0.2.2
  tftp -g -l '/usr/local/etc/dropbear/dropbear_rsa_host_key' -r "${tftp_dir_extensions}/dropbear/private_key/dropbear_rsa_host_key" 10.0.2.2

  echo 'dropbear.tcz' >> "${guest_dir_tce}/onboot.lst"
  echo '/usr/local/etc/init.d/dropbear start > /dev/null' >> '/opt/bootlocal.sh'
  echo 'usr/local/etc/dropbear/dropbear_dss_host_key'    >> '/opt/.filetool.lst'
  echo 'usr/local/etc/dropbear/dropbear_rsa_host_key'    >> '/opt/.filetool.lst'
}

install_extension_busybox_httpd() {
  tftp -g -l "${guest_dir_tcz}/busybox-httpd.tcz" -r "${tftp_dir_extensions}/busybox-httpd/busybox-httpd.tcz" 10.0.2.2

  sudo -u tc tce-load -i busybox-httpd > /dev/null

  [ -d "$guest_dir_htdocs" ] || mkdir "$guest_dir_htdocs"
  tftp -g -l "${guest_dir_htdocs}/index.html" -r "${tftp_dir_extensions}/busybox-httpd/htdocs/index.html" 10.0.2.2
  sudo chown -R tc "$guest_dir_htdocs"

  echo 'busybox-httpd.tcz' >> "${guest_dir_tce}/onboot.lst"
  echo "/usr/local/httpd/sbin/httpd -p 80 -h '${guest_dir_htdocs}' -u tc:staff" >> '/opt/bootlocal.sh'
}

prepare_bash_script() {
  fpath="$1"

  sudo sed -i 's/\r//' "$fpath"
  sudo chown tc        "$fpath"
  sudo chmod a+x       "$fpath"
}

prepare_installer_script() {
  fname="$1"

  [ -d "$guest_dir_install_scripts" ] || mkdir "$guest_dir_install_scripts"
  tftp -g -l          "${guest_dir_install_scripts}/${fname}" -r "${tftp_dir_install_scripts}/${fname}" 10.0.2.2
  prepare_bash_script "${guest_dir_install_scripts}/${fname}"
}

prepare_installer_scripts() {
  prepare_installer_script 'install_curl.sh'
  prepare_installer_script 'install_git.sh'
  prepare_installer_script 'install_python.sh'
  prepare_installer_script 'install_vim.sh'
}

prepare_custom_extras() {
  [ -d "$guest_dir_extras" ] || mkdir "$guest_dir_extras"
  tftp -g -l "${guest_dir_extras}/install_extras.sh" -r "${tftp_dir_foundation}/install_extras.sh" 10.0.2.2
  prepare_bash_script "${guest_dir_extras}/install_extras.sh"

  echo "'${guest_dir_extras}/install_extras.sh' '${guest_dir_extras}/extras.lst' '${guest_dir_tcz}' '${tftp_dir_customize}/extras.lst' '${tftp_dir_extras}' > /dev/null" >> '/opt/bootlocal.sh'
}

prepare_boot_hook() {
  tftp -g -l '/etc/hook_boot.sh' -r "${tftp_dir_foundation}/hook_boot.sh" 10.0.2.2
  prepare_bash_script '/etc/hook_boot.sh'

  echo '/etc/hook_boot.sh' >> '/opt/bootlocal.sh'
  echo 'etc/hook_boot.sh'  >> '/opt/.filetool.lst'
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
  install_extension_dropbear
  install_extension_busybox_httpd
  prepare_installer_scripts
  prepare_custom_extras
  prepare_boot_hook
  prepare_login_hook

  filetool.sh -b
}

prepare_recipe
