#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -e

readonly rwfs_file_path="/user/etc/enapter/rwfs"
readonly nm_system_connections_dir="/etc/NetworkManager/system-connections"
readonly enapter_nm_system_connections_dir="/user/etc/enapter/nm-system-connections"

if [[ ! -f "$rwfs_file_path" ]]; then
    exit 0
fi

rm -rf "$nm_system_connections_dir"

if [[ ! -d "$enapter_nm_system_connections_dir" ]]; then
    mkdir -p "$enapter_nm_system_connections_dir"
fi

ln -s "$enapter_nm_system_connections_dir" "$nm_system_connections_dir"
