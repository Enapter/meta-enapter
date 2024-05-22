#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

# no errexit, because we should cleanup before exiting
# set -o errexit

readonly podman_rw_storage=/user/var/lib/containers/storage
readonly podman_user_ro_storage=/user/images
readonly docker_compose_monit_file=/etc/monit.d/docker-compose
readonly monit_bin=/usr/bin/monit

need_remount_ro=0

if [ -x $monit_bin ]; then
  mkdir -p "$(dirname "$docker_compose_monit_file")"
  echo "" > "$docker_compose_monit_file"
fi

images_data=$(/usr/bin/podman-compose -f /user/etc/docker-compose/docker-compose.yml ps --quiet 2>/dev/null | xargs --no-run-if-empty podman inspect | jq -r 'map([.Id, .Config.Labels."com.docker.compose.service", .Image, .ImageName]) [] | join(",")')

while IFS=, read -r id service image image_name; do
  if [[ -n "$image_name" ]]; then
    # check if image already exists in cache
    # if not exists then we need to save it
    images_json_file="$podman_user_ro_storage/overlay-images/images.json"

    if [[ -f "$images_json_file" ]]; then
      existing_image_id=$(cat "$images_json_file" | jq -r ".[] | select(any(.names[]?; . == \"$image_name\") or .id == \"$id\") | .id")
    else
      existing_image_id=""
    fi

    if [[ -z "$existing_image_id" ]]; then
      echo "Image $image_name is not exists in cache (user ro images storage), saving..."

      # check if storage is not writable
      if [ ! -w "$podman_user_ro_storage/overlay-images" ]; then
        echo "Remounting to RW"
        mount -o remount,rw "$podman_user_ro_storage"
        need_remount_ro=1
      fi

      /usr/sbin/skopeo copy "containers-storage:[overlay@$podman_rw_storage]$image" "containers-storage:[overlay@$podman_user_ro_storage]$image_name"
    fi

    if [ -x $monit_bin -a -x /usr/bin/enapter-monit-docker-compose-entry-check ]; then
      printf "check program docker-compose-%s with path /usr/bin/enapter-monit-docker-compose-entry-check %s '%s'\n  if status != 0 then alert\n\n" "$service" "$id" "$service" >> "$docker_compose_monit_file"
    fi
  fi
done <<< "$images_data"

if [[ "$need_remount_ro" -eq 1 ]]; then
  echo "Remounting to RO"
  mount -o remount,ro "$podman_user_ro_storage"
fi

if [ -x $monit_bin ]; then
  $monit_bin -t && $monit_bin reload
fi
