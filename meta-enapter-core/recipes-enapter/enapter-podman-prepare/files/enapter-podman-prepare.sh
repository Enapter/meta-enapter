#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -o errexit

. /usr/share/scripts/enapter-functions

if [[ -f "$podman_storage_config" && -d "$layers_ro_mount" ]]; then
  find "$layers_ro_mount" -maxdepth 1 -mindepth 1 -type d -print0 | while IFS= read -r -d '' l; do
    if [[ -f "$l/images/overlay-images/images.lock" ]]; then
      sed -i "/# \\\$ADDITIONALIMAGESTORES\\\$/a \\ \\ ,'$l/images'" "$podman_storage_config"
    fi
  done
fi

podman info --debug

podman images

podman ps

if [ -x /user/bin/enapter-podman-pre-hook ]; then
  /user/bin/enapter-podman-pre-hook || true
fi

if [ -x /user/bin/enapter-podman-pre ]; then
  /user/bin/enapter-podman-pre || true
fi
