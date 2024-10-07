#!/bin/sh
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

if [ -f /usr/share/scripts/enapter-distro-variant ]; then
    . /usr/share/scripts/enapter-distro-variant
fi

set -eo

hostname="${DISTRO_VARIANT:-enapter}-gateway.local"

echo $hostname > /etc/hostname
hostnamectl set-hostname "$hostname"
hostnamectl set-icon-name "${DISTRO_VARIANT:-enapter}-gateway"
