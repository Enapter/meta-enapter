#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -e

readonly rwfs_file_path="/user/etc/enapter/rwfs"
readonly enapter_authorized_keys="/user/etc/enapter/authorized_keys"
readonly enapter_authorized_keys_dir=$(dirname "$enapter_authorized_keys")
readonly authorized_keys="/home/enapter/.ssh/authorized_keys"
readonly authorized_keys_dir=$(dirname "$authorized_keys")

if [[ ! -f "$rwfs_file_path" ]]; then
    exit 0
fi

if [[ ! -d "$enapter_authorized_keys_dir" ]]; then
    mkdir -p "$enapter_authorized_keys_dir"
fi

if [[ ! -f "$enapter_authorized_keys" ]]; then
    echo "" > "$enapter_authorized_keys"
fi

rm -rf "$authorized_keys"

if [[ ! -d "$authorized_keys_dir" ]]; then
    mkdir -p "$authorized_keys_dir"
fi

ln -f -s "$enapter_authorized_keys" "$authorized_keys"
chown enapter:users "$authorized_keys"
