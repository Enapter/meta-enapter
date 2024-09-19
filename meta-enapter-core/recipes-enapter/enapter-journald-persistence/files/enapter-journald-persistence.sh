#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

. /usr/share/scripts/enapter-functions

set -e

if [[ ! -f "$user_rwfs_file" ]]; then
    exit 0
fi

rm -rf "$var_log_dir"

if [[ ! -d "$user_var_log_dir" ]]; then
    mkdir -p "$user_var_log_dir"
fi
