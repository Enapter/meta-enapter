#!/bin/bash
# SPDX-FileCopyrightText: 2024 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -o errexit

. /usr/share/scripts/enapter-functions

boot_primary="$(rauc status --output-format=json 2>/dev/null | jq -rM '.boot_primary | select(.)')"

# if boot_primary is empty then system is not installed
if [ -n "$boot_primary" ]; then
  fatal "Enapter Linux appears to be already installed."
fi

# check if booted from installation media
rauc_external=$(cat /proc/cmdline | grep "rauc.external" > /dev/null && echo "1" || echo "0")
if [ "$rauc_external" -eq 0 ]; then
  fatal "Enapter Linux appears to be booted not from installation media."
fi
