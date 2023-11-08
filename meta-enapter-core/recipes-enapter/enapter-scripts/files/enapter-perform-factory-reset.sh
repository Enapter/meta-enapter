#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

if [ -L /dev/disk/by-label/enp-data-disk ] ; then
  /sbin/e2label /dev/disk/by-label/enp-data-disk "enp-data-disk-reset" && /sbin/reboot -f
fi

echo "User data disk is not set. Please set it by 'set-data-disk' command"
