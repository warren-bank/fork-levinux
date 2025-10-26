#!/bin/sh

guest_dir_confcfg="$1"
tftp_dir_wireguard="$2"
conflist_fname="$3"
confcfg_fname="$4"
select_random_line_in_file="$5"

if [ -n "$guest_dir_confcfg" -a  -n "$tftp_dir_wireguard" -a  -n "$conflist_fname" -a  -n "$confcfg_fname" -a -f "$select_random_line_in_file" ]; then

  [ -d "$guest_dir_confcfg" ] && rm -rf "$guest_dir_confcfg"
  mkdir "$guest_dir_confcfg"

  if [ -d "$guest_dir_confcfg" ]; then

    tftp -g -l "${guest_dir_confcfg}/${conflist_fname}" -r "${tftp_dir_wireguard}/${conflist_fname}" 10.0.2.2 > /dev/null 2>&1

    # read one config filename from list
    tftp_confcfg_fname=$(awk -f "$select_random_line_in_file" "${guest_dir_confcfg}/${conflist_fname}")

    if [ -n "$tftp_confcfg_fname" ]; then
      tftp -g -l "${guest_dir_confcfg}/${confcfg_fname}" -r "${tftp_dir_wireguard}/${tftp_confcfg_fname}" 10.0.2.2 > /dev/null 2>&1
    fi

  fi

fi
