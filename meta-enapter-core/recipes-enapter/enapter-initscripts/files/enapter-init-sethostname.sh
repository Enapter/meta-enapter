#!/bin/sh
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -eo pipefail

new_hostname="enapter-gateway.local"

echo $new_hostname > /etc/hostname
hostnamectl set-hostname "$new_hostname"
hostnamectl set-icon-name "enapter-gateway"
