#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -o errexit

. /usr/share/scripts/enapter-functions

enapter_systemd_machine_id=$(grub-editenv "$grubenv_path" list | sed -n 's/^enapter_systemd_machine_id=//p')

if [[ -z "$enapter_systemd_machine_id" ]]; then
  info "Machine-id is not persisted, saving to grubenv"

  machine_id="$(/bin/systemd-machine-id-setup --print)"
  if [[ -z "$machine_id" ]]; then
      fatal "Machine-id is empty"
  fi

  info "Saving machine-id"
  grub-editenv "$grubenv_path" set enapter_systemd_machine_id="$machine_id"

  info "Syncing disk"
  ensure_sync

  info "Machine-id saved"
fi
