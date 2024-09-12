#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -o errexit

. /usr/share/scripts/enapter-functions

boot_mount="/boot"

boot_success=$(grub-editenv "$grubenv_path" list | sed -n 's/^boot_success=//p')
boot_backup=$(cat /proc/cmdline | grep usebackup > /dev/null && echo "1" || echo "0")

if [[ "$boot_success" == "0" ]]; then
  fatal "Current boot is not marked as success boot. Please check why boot_success grubenv flag is set to 0!"
fi

if [[ "$boot_backup" == "1" ]]; then
  fatal "System seems to be booted with backup kernel/images. Please check why!"
fi

info "Remounting boot partition as RW"
mount -o remount,rw "$boot_mount" || fatal "Failed to remount boot partition as RW"

info "Setting grubenv variable boot_counter=1"
grub-editenv "$grubenv_path" set boot_counter=1
info "Setting grubenv variable boot_success=-1"
grub-editenv "$grubenv_path" set boot_success=-1

info "Syncing disk"
ensure_sync

info "Remounting boot partition as RO"
mount -o remount,ro "$boot_mount" || info "Failed to remount boot partition to RO, but should be OK."

info "Boot fallback enabled."
