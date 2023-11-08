#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -o errexit

info() {
  echo "[INFO] $1"
  echo
}

fatal() {
  echo 1>&2
  echo -e "${RED}[FATAL] $1${NC}" 1>&2
  echo 1>&2
  exit 1
}

boot_mount="/boot"

enapter_systemd_machine_id=$(grub-editenv "$boot_mount/EFI/BOOT/grubenv" list | sed -n 's/^enapter_systemd_machine_id=//p')

if [[ -z "$enapter_systemd_machine_id" ]]; then
  info "Machine-id is not persisted, saving to grubenv"

  machine_id="$(/bin/systemd-machine-id-setup --print)"
  if [[ -z "$machine_id" ]]; then
      fatal "Machine-id is empty"
  fi

  info "Remounting boot partition as RW"
  mount -o remount,rw "$boot_mount" || fatal "Failed to remount boot partition as RW"

  info "Saving machine-id"
  grub-editenv "$boot_mount/EFI/BOOT/grubenv" set enapter_systemd_machine_id="$machine_id"

  info "Syncing disk"
  sync; sync; sync

  info "Remounting boot partition as RO"
  mount -o remount,ro "$boot_mount" || info "Failed to remount boot partition to RO, but should be OK."

  info "Machine-id saved"
fi
