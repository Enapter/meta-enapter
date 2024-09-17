#!/bin/sh

. /usr/share/scripts/enapter-variables

# Check if the symlink already exists
if [ -L "$hdd_data_disk_device" ]; then
    exit 0
fi

# Check the PARTLABEL and create the symlink if it matches
if lsblk /dev/"$1" -o PARTLABEL | grep -q "$disk_config_label"; then
   ln -s /dev/"$1" "$hdd_data_disk_device"
fi
