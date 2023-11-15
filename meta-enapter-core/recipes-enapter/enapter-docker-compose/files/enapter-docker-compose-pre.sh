#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

# no errexit, because we should cleanup before exiting
# set -o errexit
readonly podman_rw_storage=/user/var/lib/containers/storage
readonly podman_user_ro_storage=/user/images
readonly docker_compose_images_dir="/user/etc/docker-compose/images"
readonly docker_compose_images_cache_dir="/user/etc/docker-compose/.images-cache"

need_remount_ro=0

function load_images() {
  local directory=$1

  files=$(find "$directory" -name "*.tar")

  while IFS= read -r f; do
    if [[ -n "$f" ]]; then
      echo "Loading image from file $f ..."
      # check if storage is not writable
      if [ ! -w "$podman_user_ro_storage/overlay-images" ]; then
        mount -o remount,rw "$podman_user_ro_storage"
        need_remount_ro=1
      fi

      tags=$(tar --to-stdout -xf "$f" manifest.json | jq -r '.[0].RepoTags[]?')

      echo "Image tags: $tags"

      if [[ -n "$tags" ]]; then
        while IFS= read -r tag; do
          echo "Importing tag: $tag"
          /usr/sbin/skopeo copy "docker-archive:$f" "containers-storage:[overlay@$podman_user_ro_storage]$tag"
        done <<< "$tags"
      else
        echo "$f image has no associated tags, ignoring..."
      fi

      mv "$f" "$f.imported"
    fi
  done <<< "$files"
}

load_images "$docker_compose_images_dir"
load_images "$docker_compose_images_cache_dir"

if [[ "$need_remount_ro" -eq 1 ]]; then
  mount -o remount,ro "$podman_user_ro_storage"
fi
