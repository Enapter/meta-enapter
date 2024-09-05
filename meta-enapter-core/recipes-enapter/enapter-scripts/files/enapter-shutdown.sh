#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

while true; do
  read -p "Are you sure you want to perform a shutdown? (y/n) " yn

  case $yn in
    [yY] ) echo "Ok.";
      break;;
    [nN] ) echo "Exiting...";
      exit;;
    * ) echo "Invalid response, please use (y/n).";;
  esac
done

sync

(sleep 1; systemctl --force --force poweroff) &
