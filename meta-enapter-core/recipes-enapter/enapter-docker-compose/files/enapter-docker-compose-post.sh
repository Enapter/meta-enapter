#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -e

readonly docker_compose_monit_file=/etc/monit.d/docker-compose
readonly docker_compose_images_cache_dir="/user/etc/docker-compose/.images-cache"
readonly monit_bin=/usr/bin/monit

mkdir -p "$docker_compose_images_cache_dir"

if [ -x $monit_bin ]; then
  mkdir -p "$(dirname "$docker_compose_monit_file")"
  echo "" > "$docker_compose_monit_file"
fi

/usr/bin/podman-compose -f /user/etc/docker-compose/docker-compose.yml ps --quiet 2>/dev/null | xargs --no-run-if-empty podman inspect | jq -r 'map([.Id, .Config.Labels."com.docker.compose.service", .Image, .ImageName]) [] | join(",")' | while IFS=, read -r id service image image_name; do
  image_name_fix=${image_name//\//_}
  image_name_fix=${image_name_fix//:/_}
  image_name_fix=${image_name_fix//./_}
  podman save -q --format docker-archive -o "$docker_compose_images_cache_dir/$image_name_fix.tar" "$image" || true

  if [ -x $monit_bin ]; then
    printf "check program docker-compose-%s with path /usr/bin/enapter-monit-docker-compose-entry-check %s '%s'\n  if status != 0 then alert\n\n" "$service" "$id" "$service" >> "$docker_compose_monit_file"
  fi
done

if [ -x $monit_bin ]; then
  $monit_bin -t && $monit_bin reload
fi
