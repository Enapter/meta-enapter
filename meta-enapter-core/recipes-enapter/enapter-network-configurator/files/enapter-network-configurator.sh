#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

# no errexit, because we handling non zero exit codes
# set -o errexit

info() {
  echo "[INFO] $1"
}

debug() {
  echo "[DEBUG] $1"
}

readonly boot_network_config="/boot/network.yaml"
readonly netplan_config_dir="/etc/netplan"
readonly netplan_bin="/usr/sbin/netplan"

readonly quectel_at_port="/dev/serial/by-id/usb-Quectel_Incorporated_LTE_Module-if02-port0"

if [[ ! -f "$boot_network_config" ]]; then
    exit 0
fi

if [[ ! -x "$netplan_bin" ]]; then
    exit 0
fi

dmesg | grep " register 'cdc_mbim'"
mbim_grep_exit_code=$?
debug "mbim_grep_exit_code: $mbim_grep_exit_code"

grep "modems:" "$boot_network_config"
modems_grep_exit_code=$?
debug "modems_grep_exit_code: $modems_grep_exit_code"

if [[ -e "$quectel_at_port" && "$mbim_grep_exit_code" -eq 0 && "$modems_grep_exit_code" -eq 0 ]]; then
    info "Quectel LTE modem in MBIM mode detected"

    info "Waiting for modem to settle down"

    sleep 80

    info "Waiting done"
fi

mkdir -p "$netplan_config_dir"
cp "$boot_network_config" "$netplan_config_dir/network.yaml"
chmod 600 "$netplan_config_dir/network.yaml"
$netplan_bin generate
