#!/bin/bash
# SPDX-FileCopyrightText: 2024 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -o errexit

. /usr/share/scripts/enapter-functions

update() {
    update_file="$1"
    opts="$2"

    rauc install "$opts" "$update_file"

    info "Enapter Linux successfully updated. Please reboot the PC."
}

update "$1" "$2"
