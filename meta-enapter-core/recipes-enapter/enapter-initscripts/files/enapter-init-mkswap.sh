#!/bin/sh
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -e

readonly swapfile=/user/swapfile

test -f "$swapfile" || {
  touch "$swapfile"
  df --output=fstype "$swapfile" | tail -n +2 | grep tmpfs >/dev/null && {
    echo "Skip swap file ($swapfile) allocation at tmpfs" >&2
    exit 0
  }

  dd if=/dev/zero of=$swapfile count=4096 bs=1M >/dev/null 2>&1
  chmod 600 $swapfile
  mkswap $swapfile >/dev/null 2>&1
}

if free | awk '/^Swap:/ {exit $2}'; then
  swapon "$swapfile"
fi
