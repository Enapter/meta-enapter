#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

# no errexit, because we handling non zero exit codes
# set -o errexit

. /usr/share/scripts/enapter-functions

unmount() {
  if [[ $do_unmount -eq 1 ]]; then
    umount "$usb_disk_mount"
  fi
}

usb_disk_mount="/mnt/enp_os_usb-network"
network_config="$boot_mount/$network_config_file"
do_unmount=0

if [ -L "$usb_boot_device" ] ; then
  info "USB disk with Enapter Linux detected"

  mkdir -p "$usb_disk_mount"

  mount "$usb_boot_device" -o ro "$usb_disk_mount"
  result=$?

  if [[ $result -eq 0 ]]; then
    usb_network_config="$usb_disk_mount/$network_config_file"
    do_unmount=1

    if [[ -f "$usb_network_config" ]]; then
      debug "Network config override found on USB disk"
      network_config="$usb_network_config"
    else
      debug "Network config is not found on USB disk"
    fi
  else
    error "USB disk mount failed"
  fi
fi

quectel_at_port="/dev/serial/by-id/usb-Quectel_Incorporated_LTE_Module-if02-port0"

if [[ ! -f "$network_config" ]]; then
    debug "Network config not found, exiting"
    unmount
    exit 0
fi

if [[ ! -x "$netplan_bin" ]]; then
    debug "netplan binary not found, exiting"
    unmount
    exit 0
fi

dmesg | grep " register 'cdc_mbim'"
mbim_grep_exit_code=$?
debug "mbim_grep_exit_code: $mbim_grep_exit_code"

grep "modems:" "$network_config"
modems_grep_exit_code=$?
debug "modems_grep_exit_code: $modems_grep_exit_code"

if [[ -e "$quectel_at_port" && "$mbim_grep_exit_code" -eq 0 && "$modems_grep_exit_code" -eq 0 ]]; then
    info "Quectel LTE modem in MBIM mode detected"

    info "Waiting for modem to settle down"

    sleep 80

    info "Waiting done"
fi

mkdir -p "$netplan_config_dir"
cp "$network_config" "$netplan_config_dir/$network_config_file"
chmod 600 "$netplan_config_dir/$network_config_file"
$netplan_bin generate

unmount
