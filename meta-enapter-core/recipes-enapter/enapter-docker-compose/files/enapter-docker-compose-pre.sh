#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

# no errexit, because we should cleanup before exiting
# set -o errexit

. /usr/share/scripts/enapter-functions

need_remount_ro=0

function load_images() {
  local directory=$1

  files=$(find "$directory" -name "*.tar")

  while IFS= read -r f; do
    if [[ -n "$f" ]]; then
      echo "Loading image from file $f ..."
      # check if storage is not writable
      if [ ! -w "$images_mount$overlay_images_mount" ]; then
        mount -o remount,rw "$images_mount"
        need_remount_ro=1
      fi

      tags=$(tar --to-stdout -xf "$f" manifest.json | jq -r '.[0].RepoTags[]?')

      echo "Image tags: $tags"

      if [[ -n "$tags" ]]; then
        while IFS= read -r tag; do
          echo "Importing tag: $tag"
          $skopeo_bin copy "docker-archive:$f" "containers-storage:[overlay@$images_mount]$tag"
        done <<< "$tags"
      else
        echo "$f image has no associated tags, ignoring..."
      fi

      mv "$f" "$f.imported"
    fi
  done <<< "$files"
}

load_images "$user_fs_mount/$docker_compose_images_dir"
load_images "$docker_compose_images_cache_dir"

if [[ "$need_remount_ro" -eq 1 ]]; then
  mount -o remount,ro "$images_mount"
fi

if [ -x /user/bin/enapter-docker-compose-pre ]; then
  /user/bin/enapter-docker-compose-pre || true
fi
