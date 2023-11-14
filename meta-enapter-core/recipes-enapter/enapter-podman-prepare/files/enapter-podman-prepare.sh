#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -o errexit

podman info --debug

podman ps

if [ -x /user/bin/enapter-podman-pre-hook ]; then
  /user/bin/enapter-podman-pre-hook || true
fi
