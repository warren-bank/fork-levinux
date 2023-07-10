#!/bin/sh

if [ ! -f '/home/tc/.curlrc' ]; then
  touch '/home/tc/.curlrc'
  echo "--insecure"   >> '/home/tc/.curlrc'
  echo "--silent"     >> '/home/tc/.curlrc'
  echo "--show-error" >> '/home/tc/.curlrc'

  sudo cp '/home/tc/.curlrc' '/root/.curlrc'
  sudo chown root:root '/root/.curlrc'

  tce-load -wi curl
fi
exit 0
