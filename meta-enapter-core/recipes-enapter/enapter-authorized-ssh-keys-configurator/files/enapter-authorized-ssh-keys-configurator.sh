#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

. /usr/share/scripts/enapter-functions

set -e

enapter_authorized_keys_dir=$(dirname "$user_enapter_authorized_keys")
authorized_keys_dir=$(dirname "$enapter_authorized_keys")

if [[ ! -f "$user_rwfs_file" ]]; then
    exit 0
fi

if [[ ! -d "$enapter_authorized_keys_dir" ]]; then
    mkdir -p "$enapter_authorized_keys_dir"
fi

if [[ ! -f "$user_enapter_authorized_keys" ]]; then
    echo "" > "$user_enapter_authorized_keys"
fi

rm -rf "$enapter_authorized_keys"

if [[ ! -d "$authorized_keys_dir" ]]; then
    mkdir -p "$authorized_keys_dir"
fi

ln -f -s "$user_enapter_authorized_keys" "$enapter_authorized_keys"
chown enapter:users "$enapter_authorized_keys"
