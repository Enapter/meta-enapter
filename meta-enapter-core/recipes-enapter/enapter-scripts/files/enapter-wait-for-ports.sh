#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

. /usr/share/scripts/enapter-functions

hosts=$1
timeout=${2:-1}

function wait_for_port() {
  local host=$1
  local port=$2
  local timeout=$3

  local count=0

  while :
  do
    count=$((count+1))

    if [[ $count -gt $timeout ]]; then
      echo "Wait for $host:$port timeout" >&2
      exit 1
    fi

    nc -z "$host" "$port" 2>/dev/null && return

    sleep 1
  done
}

IFS=',' read -ra hosts_arr <<< "$hosts"

for host_with_port in "${hosts_arr[@]}"; do
  host=$(echo "$host_with_port" | cut -d ':' -f 1)
  port=$(echo "$host_with_port" | cut -d ':' -f 2)

  wait_for_port "$host" "$port" "$timeout"
done
