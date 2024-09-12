#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -e

readonly var_log_dir="/var/log"
readonly enapter_var_log_dir="/user/var/log"

if [[ ! -f "$user_rwfs_file" ]]; then
    exit 0
fi

rm -rf "$var_log_dir"

if [[ ! -d "$enapter_var_log_dir" ]]; then
    mkdir -p "$enapter_var_log_dir"
fi
