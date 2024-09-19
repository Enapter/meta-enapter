#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

. /usr/share/scripts/enapter-functions

set -e

if [[ ! -f "$user_rwfs_file" ]]; then
    exit 0
fi

rm -rf "$nm_system_connections_dir"

if [[ ! -d "$user_nm_system_connections_dir" ]]; then
    mkdir -p "$user_nm_system_connections_dir"
fi

ln -s "$user_nm_system_connections_dir" "$nm_system_connections_dir"
