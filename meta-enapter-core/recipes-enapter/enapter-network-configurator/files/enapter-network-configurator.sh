#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

# no errexit, because we handling non zero exit codes
# set -o errexit

info() {
  echo "[INFO] $1"
}

error() {
  echo 1>&2
  echo -e "${RED}[ERROR] $1${NC}" 1>&2
  echo 1>&2
}

debug() {
  echo "[DEBUG] $1"
}

enp_os_usb_label="enp-os-usb"
usb_disk="/dev/disk/by-label/$enp_os_usb_label"
usb_disk_mount="/mnt/enp_os_usb"
network_config="/boot/network.yaml"

if [ -L "$usb_disk" ] ; then
  info "USB disk with Enapter Linux detected"

  mkdir -p "$usb_disk_mount"

  mount "$usb_disk" -o ro "$usb_disk_mount"
  result=$?

  if [[ $result -ne 0 ]]; then
    usb_network_config="$usb_disk_mount/network.yaml"

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

netplan_config_dir="/etc/netplan"
netplan_bin="/usr/sbin/netplan"

quectel_at_port="/dev/serial/by-id/usb-Quectel_Incorporated_LTE_Module-if02-port0"

if [[ ! -f "$network_config" ]]; then
    debug "Network config not found, exiting"
    exit 0
fi

if [[ ! -x "$netplan_bin" ]]; then
    debug "netplan binary not found, exiting"
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
cp "$network_config" "$netplan_config_dir/network.yaml"
chmod 600 "$netplan_config_dir/network.yaml"
$netplan_bin generate
