#!/bin/bash
# SPDX-FileCopyrightText: 2024 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -o errexit

. /usr/share/scripts/enapter-functions

check() {
  silent="$1"

  findmnt "$boot_mount" -o LABEL -P | grep "LABEL=\"$disk_usb_boot_label\"" > /dev/null || {
    if [[ $silent -ne 1 ]]; then
      lsblk -P -p -o "NAME,SIZE,MOUNTPOINTS,LABEL"
    fi

    fatal "Enapter Linux appears to be already installed. Please review the partitions and mounts."
  }
}

silent=0

while getopts ":s" opt; do
  case "$opt" in
    s)
      silent=1
      ;;
    :)
      fatal "Option -${OPTARG} requires an argument."
      ;;
    ?)
      fatal "Invalid option: -${OPTARG}."
      ;;
  esac
done

check "$silent"
