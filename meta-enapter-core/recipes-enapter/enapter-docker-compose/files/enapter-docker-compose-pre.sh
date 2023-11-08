#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
shopt -s nullglob

readonly rwfs_file_path="/user/etc/enapter/rwfs"
readonly docker_compose_images_dir="/user/etc/docker-compose/images"
readonly docker_compose_images_cache_dir="/user/etc/docker-compose/.images-cache"

if [[ ! -f "$rwfs_file_path" ]]; then
  exit 0
fi

function load_images() {
  local dirrectory=$1
  local image_files="$dirrectory/*.tar"

  for f in $image_files
  do
    echo "Loading image from file $f ..."
    podman load --input "$f" || true
  done
}

load_images "$docker_compose_images_cache_dir"
load_images "$docker_compose_images_dir"
