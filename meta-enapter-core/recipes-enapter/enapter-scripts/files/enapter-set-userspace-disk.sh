#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -e

. /usr/share/scripts/enapter-functions

create_fs() {
    local label=$1
    local part="/dev/disk/by-partlabel/$label"

    for f in {1..5}; do
        mkfs -t ext4 -q -F -m0 -L "$label" "$part" && return 0 || true
        echo >&2 "$part mkfs failed, looks mounted (attemp $f)"
        sleep 2
        umount "$part" || true
    done

    echo >&2 "$part mkfs failed, retries exausted"
    return 1
}

create_vfat_fs() {
    local label=$1
    local part="/dev/disk/by-partlabel/$label"

    for f in {1..5}; do
        mkfs -t vfat -F 32 -n "$label" "$part" && return 0 || true
        echo >&2 "$part mkfs failed, looks mounted (attemp $f)"
        sleep 2
        umount "$part" || true
    done

    echo >&2 "$part mkfs failed, retries exausted"
    return 1
}

[ "$#" -eq 1 ] || fatal "1 argument required"

disk="$1"

if [ ! -b "$disk" ]; then
  fatal "Device with name '$disk' does not exists"
fi

sfdisk --delete "$disk" || true

backup_part="size=512m name=$disk_backup_label type=L"
boot_part="size=8192m name=$disk_boot_label type=U"
images_part="size=16384m name=$disk_images_label type=L"
user_part="name=$disk_data_label type=L"

# shellcheck disable=SC2059
printf "$backup_part\n$boot_part\n$images_part\n$user_part" | \
  sfdisk --label gpt --force "$disk" -w always -W always

udevadm trigger --action=add
udevadm settle || sleep 3

# do not need to format bootloader partition
create_fs "$disk_backup_label" || fatal "Backup FS creation failed"
create_vfat_fs "$disk_boot_label" || fatal "Boot FS creation failed"
create_fs "$disk_images_label" || fatal "Images FS creation failed"
create_fs "$disk_data_label" || fatal "User FS creation failed"

sleep 1

ensure_sync

sleep 1 && reboot -f
