#!/bin/bash
# SPDX-FileCopyrightText: 2026 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -o errexit

. /usr/share/scripts/enapter-functions

# On Amazon EC2 the superuser account must stay locked and SSH password
# authentication must stay disabled: a cloud instance may have a public IP
# with a wide-open security group, so any password is a liability. Access
# is provided via SSH keys fetched from IMDS by enapter-cloud-init.
if running_on_ec2; then
  info "Amazon EC2 detected: keeping password locked and SSH password authentication disabled"
  exit 0
fi

password_env_file="$user_etc_enapter/$enapter_superuser_password_env_file"
if [ -f "$password_env_file" ]; then
  . "$password_env_file"
else
  # default password, can be changed and persisted via "enapter-set-password" script
  SUPERUSER_PASSWORD_HASH='@@ENAPTER_USER_PASSWD_HASH@@'
fi

usermod --password "$SUPERUSER_PASSWORD_HASH" '@@ENAPTER_USERNAME@@'

# Non-cloud installations keep the easy local access path: re-enable SSH
# password authentication via a drop-in. /etc lives on a volatile overlay,
# so this is re-created on every boot before sshd starts.
mkdir -p "$sshd_config_dir"
printf 'PasswordAuthentication yes\n' > "$sshd_config_dir/50-enapter-password-auth.conf"
