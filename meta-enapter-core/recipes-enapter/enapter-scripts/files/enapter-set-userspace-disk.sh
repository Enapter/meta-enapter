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

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument required"

disk="$1"

if [ ! -b "$disk" ]; then
  die "Device with name '$disk' does not exists"
fi

sfdisk --delete "$disk" || true

bootloader_part="start=2m size=16m name=$disk_bootloader_label type=U"
config_part="start=64m size=16m name=$disk_config_label type=L"
kernel_1_part="size=128m name=$disk_kernel_1_label type=L"
kernel_2_part="size=128m name=$disk_kernel_2_label type=L"
root_1_part="size=1536m name=$disk_root_1_label type=L"
root_2_part="size=1536m name=$disk_root_2_label type=L"
app_1_part="size=4096m name=$disk_app_1_label type=L"
app_2_part="size=4096m name=$disk_app_2_label type=L"
backup_part="size=512m name=$disk_backup_label type=L"
images_part="size=16384m name=$disk_images_label type=L"
user_part="name=$disk_data_label type=L"

# shellcheck disable=SC2059
printf "$bootloader_part\n $config_part\n $kernel_1_part\n $kernel_2_part\n $root_1_part\n $root_2_part\n $app_1_part\n $app_2_part\n $backup_part\n $images_part\n $user_part" | \
  sfdisk --label gpt --force "$disk" -w always -W always

udevadm trigger --action=add
udevadm settle || sleep 3

# do not need to format bootloader partition
# create_vfat_fs "$disk_bootloader_label" || die "Bootloader FS creation failed"
create_fs "$disk_config_label" || die "Configuration FS creation failed"
create_fs "$disk_kernel_1_label" || die "Kernel 1 FS creation failed"
create_fs "$disk_kernel_2_label" || die "Kernel 2 FS creation failed"
create_fs "$disk_root_1_label" || die "Root 1 FS creation failed"
create_fs "$disk_root_2_label" || die "Root 2 FS creation failed"
create_fs "$disk_app_1_label" || die "Application 1 FS creation failed"
create_fs "$disk_app_2_label" || die "Application 2 FS creation failed"
create_fs "$disk_backup_label" || die "Backup FS creation failed"
create_fs "$disk_images_label" || die "Images FS creation failed"
create_fs "$disk_data_label" || die "User FS creation failed"

sleep 1

ensure_sync

sleep 1 && reboot -f
