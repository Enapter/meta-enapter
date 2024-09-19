#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -o errexit

. /usr/share/scripts/enapter-functions

readonly password_env_file="$user_fs_mount$etc_enapter/$enapter_superuser_password_env_file"
password_hash=$(openssl passwd -6 -salt "$(openssl rand -hex 16)" "$1")
printf 'SUPERUSER_PASSWORD_HASH="%s"\n' "$password_hash" > "$password_env_file"
