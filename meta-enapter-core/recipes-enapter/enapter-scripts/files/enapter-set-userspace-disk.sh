#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -e

# Global constants
readonly user_label="enp-data-disk"
readonly recovery_label="enp-recovery"
readonly boot_label="enp-os"

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

printf "size=2048m name=%s type=L\n size=8192m name=%s type=U\n name=%s type=L" \
  "$recovery_label" "$boot_label" "$user_label" | sfdisk --label gpt --force "$disk" -w always -W always

udevadm trigger --action=add
udevadm settle || sleep 3

create_fs "$user_label" || die "User fs creation failed"
sleep 1
create_fs "$recovery_label" || die "Recovery fs creation failed"
sleep 1
create_vfat_fs "$boot_label" || die "Boot fs creation failed"

sync

shutdown --reboot 1 "Finished disk setup"
