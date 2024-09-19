#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

. /usr/share/scripts/enapter-functions

while true; do
  read -r -p "Are you sure you want to perform a factory reset? (y/n) " yn

  case $yn in
    [yY] ) echo "Ok.";
      break;;
    [nN] ) echo "Exiting...";
      exit;;
    * ) echo "Invalid response, please use (y/n).";;
  esac
done

if [ -L "$hdd_data_device" ] ; then
  /sbin/e2label "$hdd_data_device" "$disk_data_reset_label" && sleep 1 && /sbin/reboot -f
fi

echo "User data disk is not set. Please set it by 'set-data-disk' command"
