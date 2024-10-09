#!/bin/bash
# SPDX-FileCopyrightText: 2024 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -e

. /usr/share/scripts/enapter-functions

disk_opts="data=ordered,barrier=1,rw,nosuid,nodev,relatime"
ro_disk_opts="defaults,ro,nodev,nosuid"

rw_mode=""
status=0

test -d "$config_mount" || mkdir -p "$config_mount"

if [ -b "$hdd_config_device" ]; then
  mount "$hdd_config_device" -o "$disk_opts" "$config_mount" || { status=$?; true; }
  if [ $status -ne 0 ]; then
    echo "ERROR (fsck): failed to mount $config_mount, trying fsck -y ..."
    fsck.ext4 -yf "$hdd_config_device" || { status=$?; true; }
    if [ $status -ne 0 ]; then
      echo "ERROR (fsck): fsck -y failed, consider recovery operation"
    fi
    mount "$hdd_config_device" -o "$disk_opts" "$config_mount"
  fi
  if [[ "$grubenv_path" != "$usb_grubenv_path" ]]; then
    if [[ -L "$grubenv_path" ]]; then
      rm -f "$grubenv_path"
    fi
    if [[ ! -f "$grubenv_path" && -f "$usb_grubenv_path" ]]; then
      cp "$usb_grubenv_path" "$grubenv_path"
    fi
  fi
else
  if [[ "$grubenv_path" != "$usb_grubenv_path" ]]; then
    if [[ ! -L "$grubenv_path" && -f "$usb_grubenv_path" ]]; then
      ln -s "$usb_grubenv_path" "$grubenv_path"
    fi
  fi
fi

if [[ "$network_config_path" != "$usb_network_config_path" ]]; then
  if [[ -f "$usb_network_config_path" ]]; then
    rm -f "$network_config_path"
    cp "$usb_network_config_path" "$network_config_path"
  fi
fi

# if we have userspace disk (have a partition with user fs label) then we are in read/write mode
# else we are using temp filesystem instead of real disks
test -d "$user_fs_mount" || mkdir -p "$user_fs_mount"

if [ -b "$hdd_data_device" ]; then
  rw_mode="yes"

  fsck.ext4 -pf "$hdd_data_device" || true
  fsck.ext4 -nf "$hdd_data_device" || { status=$?; true; }
  if [ $status -ne 0 ]; then
    echo "ERROR (fsck): $hdd_data_device seems to be corrupted, consider recovery operation"
  fi

  mount "$hdd_data_device" -o "$disk_opts" "$user_fs_mount" || { status=$?; true; }
  if [ $status -ne 0 ]; then
    echo "ERROR (fsck): failed to mount $hdd_data_device, trying fsck -y ..."
    fsck.ext4 -yf "$hdd_data_device" || { status=$?; true; }
    if [ $status -ne 0 ]; then
      echo "ERROR (fsck): fsck -y failed, consider recovery operation"
    fi
    mount "$hdd_data_device" -o "$disk_opts" "$user_fs_mount"
  fi
fi

# create userspace directories structure
for dir in bin etc lib lib64 libexec share sbin var var/lib tmp /images $docker_compose_dir $docker_compose_images_dir ; do
  test -d "$user_fs_mount/$dir" || mkdir -p "$user_fs_mount/$dir"
done

# cleanup /var/tmp, due to bug in 2.1.0-beta1
test -d "$user_fs_mount/var/tmp" && rm -rf "$user_fs_mount/var/tmp"
# tmp should be clean after each reboot, its just a rule for /tmp dirs
# we use find command here to not delete directory itself, only files
test -d "$user_fs_mount/tmp" && find "$user_fs_mount/tmp" -mindepth 1 -delete

# cleanup for Podman, because Podman can boot with corrupted state
# and its hard to fix it when gateway already booted
rm -rf "$user_fs_mount/var/lib/containers"
rm -rf "$user_fs_mount/run/containers"

# cleaup of unpacked images dir to be sure we are starting clean
rm -rf "$user_fs_mount/usr/share/enapter"

if [ ! -f "$user_fs_mount/$docker_compose_file" ]; then
  cp /usr/share/examples/docker-compose.yml "$user_fs_mount/$docker_compose_file"
fi

if [ ! -f "$user_fs_mount/$docker_compose_images_readme_file" ]; then
  cp /usr/share/examples/docker-images-readme.txt "$user_fs_mount/$docker_compose_images_readme_file"
fi

if [ -n "$rw_mode" ]; then
  mkdir -p "$user_etc_enapter"
  # if we are in read/write mode then create special file
  touch "$user_fs_mount$etc_enapter/$rwfs_file"

  # if we have backup disk (have a partition with enp-backup label) then we mount it
  if [ -b "$hdd_backup_device" ]; then
    test -d "$backup_mount" || mkdir -p "$backup_mount"

    mount "$hdd_backup_device" -t "auto" -o "$ro_disk_opts" "$backup_mount"
  fi

  # if we have export data disk (have a partition with enp-export label) then we mount it
  if [ -b "$disk_export_label" ]; then
    test -d "$export_mount" || mkdir -p "$export_mount"

    mount "$disk_export_label" -t "auto" -o "$ro_disk_opts" "$export_mount"
  else
    test -d "$user_fs_mount/$export_mount" || mkdir -p "$user_fs_mount/$export_mount"
    test -d "$export_mount" || ln -s "$user_fs_mount/$export_mount" "$export_mount"
  fi

  # if we have images data disk (have a partition with enp-images label) then we mount it
  if [ -b "$hdd_images_device" ]; then
    test -d "$images_mount" || mkdir -p "$images_mount"

    mount "$hdd_images_device" -t "auto" -o "$ro_disk_opts" "$images_mount"

    if [ ! -f "$images_mount$overlay_images_lock" ]; then
      mount -o "remount,rw" "$images_mount"
      mkdir -p "$images_mount$overlay_images_mount"
      openssl rand -hex 32 | tr -d '\n' > "$images_mount$overlay_images_lock"
      mkdir -p "$images_mount$overlay_layers_mount"
      openssl rand -hex 32 | tr -d '\n' > "$images_mount$overlay_layers_lock"
      sync; sync; sync
      mount -o "remount,ro" "$images_mount"
    fi
  else
    test -d "$images_mount" || mkdir -p "$images_mount"

    if [ ! -f "$images_mount$overlay_images_lock" ]; then
      mkdir -p "$images_mount$overlay_images_mount"
      openssl rand -hex 32 | tr -d '\n' > "$images_mount$overlay_images_lock"
      mkdir -p "$images_mount$overlay_layers_mount"
      openssl rand -hex 32 | tr -d '\n' > "$images_mount$overlay_layers_lock"
      sync; sync; sync
    fi
  fi
fi
