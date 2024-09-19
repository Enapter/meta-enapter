#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

default_interface=$(/sbin/ip route | grep 'default via' | head -n1 | awk '{print $5}')
if [[ -z "$default_interface" ]]; then
  echo "[ERROR] default network interface not found"
  echo ""
  echo "Troubleshooting steps:"
  echo "  1. If you changed DHCP settings in your network, please reboot the gateway."
  echo "  2. Make sure that the Ethernet cable is plugged in and the control LEDs are lit up."
  echo "  3. If you are using a WiFi connection, please check settings and ensure the WiFi signal level is sufficient."
  exit 1
fi
/sbin/ip address show dev "$default_interface" | sed -n 's/^.*inet \([0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+\).*$/\1/p'
