#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -ex

limit_seconds=600
boot_success=$(grub-editenv /boot/EFI/BOOT/grubenv list | sed -n 's/^boot_success=//p')
boot_backup=$(cat /proc/cmdline | grep usebackup > /dev/null && echo "1" || echo "0")
uptime=$(awk '{printf "%0.f", $1}' < /proc/uptime)

if [[ "$boot_success" == "0" && "$boot_backup" == "0" ]]; then
  if [[ "$uptime" -gt $limit_seconds ]]; then
    echo "Rebooting due to current boot is not marked as success in $limit_seconds seconds"
    reboot -f
  fi
fi
