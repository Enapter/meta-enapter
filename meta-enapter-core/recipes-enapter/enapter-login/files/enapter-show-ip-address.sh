#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

default_interface=$(/sbin/ip route | grep 'default via' | head -n1 | awk '{print $5}')
if [[ -z "$default_interface" ]]; then
  echo "[ERROR] default network interface not found"
  exit 1
fi
/sbin/ip address show dev $default_interface | sed -n 's/^.*inet \([0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+\).*$/\1/p'
