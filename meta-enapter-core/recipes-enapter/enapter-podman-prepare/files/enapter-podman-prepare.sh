#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -o errexit

podman_storage_config="/etc/containers/storage.conf"
layers_dir="/layers"

if [[ -f "$podman_storage_config" && -d "$layers_dir" ]]; then
  layers=$(find "$layers_dir" -maxdepth 1 -mindepth 1 -type d)

  for l in "$layers"; do
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
