#!/usr/bin/env bash

url='http://ipv4.icanhazip.com/'
proxy='socks5h://localhost:1080'

ip_real=$(curl --silent "$url")
ip_vpn=$(curl --silent --proxy "$proxy" "$url")

echo "real IP: ${ip_real}"
echo "VPN  IP: ${ip_vpn}"
echo ''

function bad_real() {
  echo 'ERROR: Bad internet connection'
  exit 1
}

function bad_vpn() {
  echo 'ERROR: VPN is not ready'
  exit 2
}

function same_ip() {
  echo 'ERROR: VPN is not working'
  exit 3
}

[ -z "$ip_real" ]           && bad_real
[ -z "$ip_vpn" ]            && bad_vpn
[ "$ip_real" == "$ip_vpn" ] && same_ip

echo 'SUCCESS: VPN is working'
exit 0
