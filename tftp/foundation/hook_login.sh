#!/bin/sh

echo -e "\e[00;36m"
echo "-------------------------------------------------------------------------------"
echo -e "SSH    client: \e[1;37mssh tc@localhost -p 2222\e[00;36m"
echo -e "SOCKS5 client: \e[1;37mlocalhost:1080\e[00;36m"
echo ""
echo -e "su root:  \e[1;37msudo -s\e[00;36m"
echo -e "reboot:   \e[1;37msudo reboot\e[00;36m"
echo -e "shutdown: \e[1;37msudo poweroff\e[00;36m"
echo "-------------------------------------------------------------------------------"
echo -e "\e[00m"
echo ""
