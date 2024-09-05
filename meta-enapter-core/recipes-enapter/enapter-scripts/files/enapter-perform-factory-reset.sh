#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

while true; do
  read -p "Are you sure you want to perform a factory reset? (y/n) " yn

  case $yn in
    [yY] ) echo "Ok.";
      break;;
    [nN] ) echo "Exiting...";
      exit;;
    * ) echo "Invalid response, please use (y/n).";;
  esac
done

if [ -L /dev/disk/by-label/enp-data-disk ] ; then
  /sbin/e2label /dev/disk/by-label/enp-data-disk "enp-data-reset" && sleep 1 && /sbin/reboot -f
fi

echo "User data disk is not set. Please set it by 'set-data-disk' command"
