#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -o errexit

. /usr/share/scripts/enapter-functions

conn_name=$(/usr/bin/nmcli --colors=no --terse --field name,type conn show | grep "802-11-wireless" | sed "s/:802-11-wireless//")

if [[ -n $conn_name ]]; then
  conn_count=$(echo "$conn_name" | wc -l)

  if [[ $conn_count -gt 1 ]]; then
    info "Connections: $conn_name"
    fatal "More than one wifi connection found, this case is not supported"
  fi

  active_conf_lines=$(/usr/bin/nmcli --colors=no --terse conn show --active "$conn_name" | wc -l)

  if [[ $active_conf_lines -eq 0 ]]; then
    info "Connection '$conn_name' seems to be inactive, activating it now."
    /usr/bin/nmcli conn up "$conn_name"
  fi
fi
