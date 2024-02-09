#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -o errexit

RED='\033[0;31m'
NC='\033[0m' # No Color

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

install() {
    yes="$1"
    disk_boot_label="enp-os"
    hdd_boot_device="/dev/disk/by-label/$disk_boot_label"

    boot_mount="/boot"
    hdd_boot_mount="/mnt/boot"

    findmnt "$boot_mount" -o LABEL -P | grep "LABEL=\"enp-os-usb\"" > /dev/null || {
      lsblk -P -p -o "NAME,SIZE,MOUNTPOINTS,LABEL"
      fatal "Enapter Linux seems to be already installed, please review partitions and mounts."
    }

    if [[ ! -L "$hdd_boot_device" ]]; then
      fatal "Partition with label enp-os (installation disk) not found, please do Enapter Gateway setup first."
    fi

    if [[ $yes -ne 1 ]]; then
        while true; do
          read -p "Are you sure you want to proceed with installation Enapter Linux on HDD? (y/n) " yn

          case $yn in 
            [yY] ) info "Ok, we will proceed";
              break;;
            [nN] ) info "Exiting...";
              exit;;
            * ) info "Invalid response, please use (y/n).";
              exit 1;;
          esac
        done
    fi

    info "Mounting HDD boot partition"
    mkdir -p ${hdd_boot_mount}
    mountpoint -q ${hdd_boot_mount} || mount -v ${hdd_boot_device} ${hdd_boot_mount}

    os_files=$(find "$boot_mount" -not -path '*/.*' -type f | sed 's|^/boot/||')

    while IFS= read -r f; do
      if [[ -n "$f" ]]; then
        if [[ -f "$hdd_boot_mount/$f" ]]; then
          fatal "Enapter Linux seems to be already installed on HDD disk (/mnt/boot), but system booted from USB. If you want to overwrite installed files, please remove them manually."
        fi
      fi
    done <<< "$os_files"

    if [[ ! -w ${hdd_boot_mount} ]]; then
      fatal "HDD boot partition is not available for writing. Please check logs above for more details."
    fi

    info "Copying system files, please wait..."

    while IFS= read -r f; do
      if [[ -n "$f" ]]; then
        if [[ -f "$boot_mount/$f" ]]; then
          mkdir -v -p "$hdd_boot_mount/$(dirname "$f")"
          cp -v -f "$boot_mount/$f" "$hdd_boot_mount/$f" || fatal "Failed to copy $f file, aborting installation halfway. Please do cleanup before reboot."
        fi
      fi
    done <<< "$os_files"

    info "Syncing disks"
    sync; sync; sync

    info "Unmounting HDD boot partition"
    umount ${hdd_boot_mount} || info "Failed to unmount HDD boot partition, but should be OK."

    info "Enapter Linux successfully installed on HDD disk, please remove installation media (USB stick) and reboot PC."
}

OPTIND=1
yes=0

while getopts "y" opt; do
  case "$opt" in
    y)
      yes=1
      ;;
    ?)
      echo "Invalid option: -${OPTARG}."
      exit 1
      ;;
  esac
done
shift "$((OPTIND-1))"   # Discard the options and sentinel --

install "$yes"
