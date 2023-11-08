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

boot_backup=$(cat /proc/cmdline | grep usebackup > /dev/null && echo "1" || echo "0")

if [[ "$boot_backup" == "1" ]]; then
  fatal "System seems to be booted with backup kernel/images. Please check why!"
fi

info "Remounting boot partition as RW"
mount -o remount,rw "$boot_mount" || fatal "Failed to remount boot partition as RW"

info "Setting grubenv variable boot_success=1"
grub-editenv "$boot_mount/EFI/BOOT/grubenv" set boot_success=1

info "Syncing disk"
sync; sync; sync

info "Remounting boot partition as RO"
mount -o remount,ro "$boot_mount" || info "Failed to remount boot partition to RO, but should be OK."

info "Boot marked as success boot."
