#!/bin/sh

guest_file_extras="$1"
guest_dir_tcz="$2"
tftp_file_extras="$3"
tftp_dir_tcz="$4"

if [ -n "$guest_file_extras" -a -n "$tftp_file_extras" ]; then
  tftp -g -l "$guest_file_extras" -r "$tftp_file_extras" 10.0.2.2
fi

if [ -f "$guest_file_extras" -a -d "$guest_dir_tcz" -a -n "$tftp_dir_tcz" ]; then
  while read package; do
    case "$package" in \#*) continue ;; esac
    [ -z "$package" ] && continue

    guest_file_tcz="${guest_dir_tcz}/${package}.tcz"
    if [ ! -f "$guest_file_tcz" ]; then
      tftp -g -l "$guest_file_tcz" -r "${tftp_dir_tcz}/${package}.tcz" 10.0.2.2
    fi

    sudo -u tc tce-load -i "$package" > /dev/null
  done < "$guest_file_extras"
fi
