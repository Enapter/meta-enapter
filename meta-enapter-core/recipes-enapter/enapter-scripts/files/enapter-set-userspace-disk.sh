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

[ "$#" -eq 1 ] || fatal "1 argument required"

disk="$1"

if [ ! -b "$disk" ]; then
  fatal "Device with name '$disk' does not exists"
fi

sfdisk --delete "$disk" || true

bootloader_part="start=2m size=16m name=$disk_bootloader_label type=U"
config_part="start=64m size=16m name=$disk_config_label type=L"
kernel_a_part="size=128m name=$disk_kernel_a_label type=L"
root_a_part="size=1536m name=$disk_root_a_label type=L"
app_a_part="size=4096m name=$disk_app_a_label type=L"
kernel_b_part="size=128m name=$disk_kernel_b_label type=L"
root_b_part="size=1536m name=$disk_root_b_label type=L"
app_b_part="size=4096m name=$disk_app_b_label type=L"
backup_part="size=512m name=$disk_backup_label type=L"
images_part="size=16384m name=$disk_images_label type=L"
user_part="name=$disk_data_label type=L"

# shellcheck disable=SC2059
printf "$bootloader_part\n $config_part\n $kernel_a_part\n $root_a_part \n$app_a_part\n $kernel_b_part\n $root_b_part\n $app_b_part\n $backup_part\n $images_part\n $user_part" | \
  sfdisk --label gpt --force "$disk" -w always -W always

udevadm trigger --action=add
udevadm settle || sleep 3

# TODO: check if disk size at least ??? GB

# do not need to format bootloader partition
# create_vfat_fs "$disk_bootloader_label" || fatal "Bootloader FS creation failed"
create_fs "$disk_config_label" || fatal "Configuration FS creation failed"
create_fs "$disk_kernel_a_label" || fatal "Kernel 1 FS creation failed"
create_fs "$disk_root_a_label" || fatal "Root 1 FS creation failed"
create_fs "$disk_app_a_label" || fatal "Application 1 FS creation failed"
create_fs "$disk_kernel_b_label" || fatal "Kernel 2 FS creation failed"
create_fs "$disk_root_b_label" || fatal "Root 2 FS creation failed"
create_fs "$disk_app_b_label" || fatal "Application 2 FS creation failed"
create_fs "$disk_backup_label" || fatal "Backup FS creation failed"
create_fs "$disk_images_label" || fatal "Images FS creation failed"
create_fs "$disk_data_label" || fatal "User FS creation failed"

sleep 1

ensure_sync

sleep 1 && reboot -f
