#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -e

readonly boot_network_config="/boot/network.yaml"
readonly netplan_config_dir="/etc/netplan"
readonly netplan_bin="/usr/sbin/netplan"

if [[ ! -f "$boot_network_config" ]]; then
    exit 0
fi

if [[ ! -x "$netplan_bin" ]]; then
    exit 0
fi

mkdir -p "$netplan_config_dir"
ln -s "$boot_network_config" "$netplan_config_dir/network.yaml"
$netplan_bin generate
