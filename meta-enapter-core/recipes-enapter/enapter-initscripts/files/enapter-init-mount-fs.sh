#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

# - Mount disk or temp FS to /user (for enapter's data)
# - Mount disk to /recovery (for enapter's recovery data)
# - Mount disk or create symlink for /export (for enapter's export data)
# - Mount disk or create a directory for /user/images (for user images data)

set -e

# Global constants
readonly user_fs_label="enp-data-disk"
readonly user_fs_mountpoint="/user"

readonly recovery_fs_label="enp-recovery"
readonly recovery_fs_mountpoint="/recovery"
readonly recovery_disk_path="/dev/disk/by-label/$recovery_fs_label"

readonly export_fs_label="enp-export"
readonly export_fs_mountpoint="/export"
readonly export_disk_path="/dev/disk/by-label/$export_fs_label"

readonly images_fs_label="enp-images"
readonly images_fs_mountpoint="/user/images"
readonly images_disk_path="/dev/disk/by-label/$images_fs_label"

readonly disk_opts="data=ordered,barrier=1,rw,nosuid,nodev,relatime"
readonly ro_disk_opts="defaults,ro,nodev,nosuid"

readonly docker_compose_dir="etc/docker-compose"
readonly docker_compose_images_dir="$docker_compose_dir/images"
readonly docker_compose_file="$docker_compose_dir/docker-compose.yml"
readonly docker_compose_images_readme_file="$docker_compose_images_dir/readme.txt"

user_disk_path="/dev/disk/by-label/$user_fs_label"
# if we have userspace disk (have a partition with user fs label) then we are in read/write mode
# else we are using temp filesystem instead of real disks
if [ -b "$user_disk_path" ]; then
  rw_mode="yes"
  user_disk_type="auto"
else
  rw_mode=""
  user_disk_path='tmpfs'
  user_disk_type='tmpfs'
fi

status=0

fsck.ext4 -pf "$user_disk_path" || true
fsck.ext4 -nf "$user_disk_path" || { status=$?; true; }
if [ $status -ne 0 ]; then
  echo "ERROR (fsck): $user_disk_path seems to be corrupted, consider recovery operation"
fi

# create mountpoint if not exists
test -d "$user_fs_mountpoint" || mkdir -p "$user_fs_mountpoint"

mount "$user_disk_path" -t "$user_disk_type" -o "$disk_opts" "$user_fs_mountpoint" || { status=$?; true; }
if [ $status -ne 0 ]; then
  echo "ERROR (fsck): failed to mount $user_disk_path, trying fsck -y ..."
  fsck.ext4 -yf "$user_disk_path" || { status=$?; true; }
  if [ $status -ne 0 ]; then
    echo "ERROR (fsck): fsck -y failed, consider recovery operation"
  fi
  mount "$user_disk_path" -t "$user_disk_type" -o "$disk_opts" "$user_fs_mountpoint"
fi

# create userspace directories structure
for dir in bin etc lib lib64 libexec share sbin var var/lib tmp /images $docker_compose_dir $docker_compose_images_dir ; do
  test -d "$user_fs_mountpoint/$dir" || mkdir -p "$user_fs_mountpoint/$dir"
done

# cleanup /var/tmp, due to bug in 2.1.0-beta1
test -d "$user_fs_mountpoint/var/tmp" && rm -rf "$user_fs_mountpoint/var/tmp"
# tmp should be clean after each reboot, its just a rule for /tmp dirs
# we use find command here to not delete directory itself, only files
test -d "$user_fs_mountpoint/tmp" && find "$user_fs_mountpoint/tmp" -mindepth 1 -delete

# cleanup for Podman, because Podman can boot with corrupted state
# and its hard to fix it when gateway already booted
rm -rf "$user_fs_mountpoint/var/lib/containers"
rm -rf "$user_fs_mountpoint/run/containers"

# cleaup of unpacked images dir to be sure we are starting clean
rm -rf "$user_fs_mountpoint/usr/share/enapter"

if [ ! -f "$user_fs_mountpoint/$docker_compose_file" ]; then
    cat << EOF > "$user_fs_mountpoint/$docker_compose_file"
# Docker Compose documentation: https://docs.docker.com/compose/
version: "3"

# Uncomment the lines below (remove \`#\` symbol) to run Grafana on the gateway.
# It's already configured with Enapter datasource plugin, no further configuration needed.
# Grafana will be available on port :3000 on the gateway, e.g. http://enapter-gateway.local:3000
# Enapter datasource documentation: https://go.enapter.com/grafana-docs
#
# Run \`systemctl restart enapter-docker-compose\` after updating this file.
#
#services:
#  grafana:
#    user: root
#    ports:
#      - '0.0.0.0:3000:3000'
#    env_file: /user/etc/enapter/enapter-token.env
#    environment:
#      - 'TELEMETRY_API_BASE_URL=http://10.88.0.1/api/telemetry'
#    volumes:
#      - /user/grafana-data:/var/lib/grafana
#    image: enapter/grafana-with-telemetry-datasource-plugin
EOF
fi

if [ ! -f "$user_fs_mountpoint/$docker_compose_images_readme_file" ]; then
    cat << EOF > "$user_fs_mountpoint/$docker_compose_images_readme_file"
Docker images (in tar format) placed in this directory will be automatically loaded after Enapter Gateway restart.

It is typically used for Docker images not available in the public registries, e.g. company private Docker registries.
EOF
fi

if [ -n "$rw_mode" ]; then
  mkdir -p "$user_fs_mountpoint/etc/enapter"
  # if we are in read/write mode then create special file
  touch "$user_fs_mountpoint/etc/enapter/rwfs"

  # if we have recovery disk (have a partition with enp-recovery label) then we mount it
  if [ -b "$recovery_disk_path" ]; then
    test -d "$recovery_fs_mountpoint" || mkdir -p "$recovery_fs_mountpoint"

    mount "$recovery_disk_path" -t "auto" -o "$ro_disk_opts" "$recovery_fs_mountpoint"
  fi

  # if we have export data disk (have a partition with enp-export label) then we mount it
  if [ -b "$export_disk_path" ]; then
    test -d "$export_fs_mountpoint" || mkdir -p "$export_fs_mountpoint"

    mount "$export_disk_path" -t "auto" -o "$ro_disk_opts" "$export_fs_mountpoint"
  else
    test -d "$user_fs_mountpoint/export" || mkdir -p "$user_fs_mountpoint/export"
    test -d "$export_fs_mountpoint" || ln -s "$user_fs_mountpoint/export" "$export_fs_mountpoint"
  fi

  # if we have images data disk (have a partition with enp-images label) then we mount it
  if [ -b "$images_disk_path" ]; then
    test -d "$images_fs_mountpoint" || mkdir -p "$images_fs_mountpoint"

    mount "$images_disk_path" -t "auto" -o "$ro_disk_opts" "$images_fs_mountpoint"

    if [ ! -f "$images_fs_mountpoint/overlay-images/images.lock" ]; then
      mount -o "remount,rw" "$images_fs_mountpoint"
      mkdir -p "$images_fs_mountpoint/overlay-images"
      openssl rand -hex 32 | tr -d '\n' > "$images_fs_mountpoint/overlay-images/images.lock"
      mkdir -p "$images_fs_mountpoint/overlay-layers"
      openssl rand -hex 32 | tr -d '\n' > "$images_fs_mountpoint/overlay-layers/layers.lock"
      sync; sync; sync
      mount -o "remount,ro" "$images_fs_mountpoint"
    fi
  else
    test -d "$images_fs_mountpoint" || mkdir -p "$images_fs_mountpoint"

    if [ ! -f "$images_fs_mountpoint/overlay-images/images.lock" ]; then
      mkdir -p "$images_fs_mountpoint/overlay-images"
      openssl rand -hex 32 | tr -d '\n' > "$images_fs_mountpoint/overlay-images/images.lock"
      mkdir -p "$images_fs_mountpoint/overlay-layers"
      openssl rand -hex 32 | tr -d '\n' > "$images_fs_mountpoint/overlay-layers/layers.lock"
      sync; sync; sync
    fi
  fi
fi
