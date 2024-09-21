#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -o errexit

. /usr/share/scripts/enapter-functions

UPDATE_FILES="bzImage
initrd
rootfs.img
grubx64.efi
grub.cfg
version.txt
SHA256SUMS"

update() {
    update_file="$1"
    opts="$2"

    if [[ ! -L "$hdd_boot_device" ]]; then
      fatal "Partition with label $disk_boot_label (installation disk) not found, please do Enapter Gateway setup first."
    fi

    info "Unpacking update file..."

    full_update_path=$(readlink -f "$update_file")
    update_dir=$(dirname "$full_update_path")
    tmp_dir=$(mktemp --directory --tmpdir="$update_dir")

    unzip "$full_update_path" -d "$tmp_dir"

    info "Checking update file..."

    for f in $UPDATE_FILES;
    do
      if [[ ! -f "$tmp_dir/$f" ]]; then
        fatal "Update bundle missing required file: $f"
      fi
    done

    pushd "$tmp_dir"
    sha256sum -c SHA256SUMS
    checksums_ok=$?
    if [[ "$checksums_ok" -ne 0 ]]; then
      fatal "Checksums mismatch! Exiting..."
    fi
    popd

    info "Update file OK"

    while true; do
      read -r -p "Are you sure you want to proceed with Enapter Linux update? (y/n) " yn

      case $yn in 
        [yY] ) info "Ok, we will proceed";
          break;;
        [nN] ) info "Exiting...";
          exit;;
        * ) info "Invalid response, please use (y/n).";;
      esac
    done

    /usr/bin/enapter-boot-fallback-enable
    result=$?
    if [[ "$result" -ne 0 ]]; then
      fatal "Update failed!"
    fi

    info "Re-mounting boot partition as R/W"
    mount -v -o remount,rw ${boot_mount}

    if [[ ! -w ${boot_mount} ]]; then
      fatal "HDD boot partition is not available for writing. Please check logs above for more details."
    fi

    info "Removing backup files from previous update"

    rm -fv "$boot_mount$efi_enapter"/*.backup
    rm -fv "$boot_mount$layers"/*.backup

    info "Creating backup, please wait"

    cp -vf "$boot_mount$efi_enapter/bzImage" "$boot_mount$efi_enapter/bzImage.backup"
    ensure_sync
    cp -vf "$boot_mount$efi_enapter/initrd" "$boot_mount$efi_enapter/initrd.backup"
    ensure_sync

    info "Updating bootloader."

    cp -vf "$tmp_dir/grubx64.efi" "$boot_mount$efi_boot/grubx64.efi"
    ensure_sync
    cp -vf "$tmp_dir/grub.cfg" "$boot_mount$efi_boot/grub.cfg"
    ensure_sync

    info "Copying system files, please wait..."

    cp -vf "$tmp_dir/bzImage" "$boot_mount$efi_enapter/bzImage"
    ensure_sync
    cp -vf "$tmp_dir/initrd" "$boot_mount$efi_enapter/initrd"
    ensure_sync
    cp -vf "$tmp_dir/rootfs.img" "$boot_mount$efi_enapter/rootfs.img.update"
    ensure_sync
    cp -vf "$tmp_dir/version.txt" "$boot_mount$efi_enapter/version.txt.update"
    ensure_sync

    if [[ -f "$tmp_dir/enapter-iot.img" ]]; then
      cp -vf "$tmp_dir/enapter-iot.img" "$boot_mount$layers/enapter-iot.img.update"
      ensure_sync
    fi

    if [[ -f "$tmp_dir/enapter-iot-enterprise.img" ]]; then
      cp -vf "$tmp_dir/enapter-iot-enterprise.img" "$boot_mount$layers/enapter-iot-enterprise.img.update"
      ensure_sync
    fi

    info "Re-mounting boot partition as R/O"
    mount -v -o remount,ro ${boot_mount} || info "Failed to remount boot partition as R/O, but should be OK."

    rm -rf "$tmp_dir"

    info "Enapter Linux successfully updated, please run do reboot and 'enapter-boot-success' command after success boot to finish update."
}

update "$1" "$2"
