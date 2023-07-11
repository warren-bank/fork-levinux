#!/bin/sh

guest_dir_ovpncfg="$1"
tftp_dir_openvpn="$2"
ovpnlist_fname="$3"
ovpnauth_fname="$4"
ovpncfg_fname="$5"
select_random_line_in_file="$6"
filter_openvpn_config="$7"

if [ -n "$guest_dir_ovpncfg" -a  -n "$tftp_dir_openvpn" -a  -n "$ovpnlist_fname" -a  -n "$ovpnauth_fname" -a  -n "$ovpncfg_fname" -a -f "$select_random_line_in_file" ]; then

  [ -d "$guest_dir_ovpncfg" ] && rm -rf "$guest_dir_ovpncfg"
  mkdir "$guest_dir_ovpncfg"

  if [ -d "$guest_dir_ovpncfg" ]; then

    tftp -g -l "${guest_dir_ovpncfg}/${ovpnlist_fname}" -r "${tftp_dir_openvpn}/${ovpnlist_fname}" 10.0.2.2 > /dev/null 2>&1
    tftp -g -l "${guest_dir_ovpncfg}/${ovpnauth_fname}" -r "${tftp_dir_openvpn}/${ovpnauth_fname}" 10.0.2.2 > /dev/null 2>&1

    # read one config filename from list
    tftp_ovpncfg_fname=$(awk -f "$select_random_line_in_file" "${guest_dir_ovpncfg}/${ovpnlist_fname}")

    if [ -n "$tftp_ovpncfg_fname" ]; then
      tftp -g -l "${guest_dir_ovpncfg}/${ovpncfg_fname}.full" -r "${tftp_dir_openvpn}/${tftp_ovpncfg_fname}" 10.0.2.2 > /dev/null 2>&1

      "$filter_openvpn_config" "${guest_dir_ovpncfg}/${ovpncfg_fname}.full" "${guest_dir_ovpncfg}/${ovpncfg_fname}"
    fi

  fi

fi
