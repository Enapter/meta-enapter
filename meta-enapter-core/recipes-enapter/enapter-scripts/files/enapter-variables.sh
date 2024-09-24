# Helper shell variables
#
# SPDX-FileCopyrightText: 2024 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

rootfs_patch_script="patch_rootfs.sh"

disk_bootloader_label="enp-boot"
disk_config_label="enp-config"
disk_kernel_a_label="enp-kernel-a"
disk_kernel_b_label="enp-kernel-b"
disk_root_a_label="enp-root-a"
disk_root_b_label="enp-root-b"
disk_app_a_label="enp-app-a"
disk_app_b_label="enp-app-b"
disk_boot_label="enp-os"
disk_data_label="enp-data-disk"
disk_data_reset_label="enp-data-reset"
disk_backup_label="enp-backup"
disk_images_label="enp-images"
disk_usb_boot_label="enp-os-usb"
disk_export_label="enp-export"

boot_mount="/boot"
hdd_boot_mount="/mnt/boot"
app_ro_mount="/mnt/app_ro"
root_ro_mount="/mnt/overlay_ro"
root_rw_mount="/mnt/overlay_rw"
config_mount="/mnt/config"
images_mount="/mnt/images"
user_fs_mount="/user"
backup_mount="/backup"
export_mount="/export"
layers_ro_mount="/mnt/layers"
root_mount="/"
overlay_images_mount="/overlay-images"
overlay_layers_mount="/overlay-layers"
overlay_images_lock="$overlay_images_mount/images.lock"
overlay_images_config="$overlay_images_mount/images.json"
overlay_layers_lock="$overlay_layers_mount/layers.lock"
enapter_superuser_password_env_file="enapter-superuser-password.env"
etc_enapter="/etc/enapter"
user_etc_enapter="$user_fs_mount$etc_enapter"
rwfs_file="rwfs"
user_rwfs_file="$user_etc_enapter/$rwfs_file"
user_enapter_authorized_keys="$user_etc_enapter/authorized_keys"
enapter_authorized_keys="/home/enapter/.ssh/authorized_keys"
layers_base_dir="layers"
overlayfs_upperdir="$root_rw_mount/upperdir"
overlayfs_workdir="$root_rw_mount/work"
efi_enapter_dir="EFI/enapter"
efi_boot_dir="EFI/BOOT"
efi_enapter="$root_mount$efi_enapter_dir"
efi_boot="$root_mount$efi_boot_dir"

usb_boot_device="/dev/disk/by-label/$disk_usb_boot_label"
hdd_boot_device="/dev/disk/by-label/$disk_boot_label"
hdd_data_device="/dev/disk/by-label/$disk_data_label"
hdd_data_reset_device="/dev/disk/by-label/$disk_data_reset_label"
hdd_backup_device="/dev/disk/by-label/$disk_backup_label"
hdd_export_device="/dev/disk/by-label/$disk_export_label"
hdd_images_device="/dev/disk/by-label/$disk_images_label"
hdd_data_disk_device="/dev/data-disk"
hdd_config_device="/dev/disk/by-label/$disk_config_label"

grubenv_file="grubenv"
usb_grubenv_path="$boot_mount/EFI/BOOT/$grubenv_file"
grubenv_path="$config_mount/$grubenv_file"
grub_editenv="/usr/bin/grub-editenv"

network_config_file="network.yaml"
usb_network_config_path="$boot_mount/$network_config_file"
network_config_path="$config_mount/$network_config_file"

netplan_config_dir="/etc/netplan"
netplan_bin="/usr/sbin/netplan"

docker_compose_dir="etc/docker-compose"
docker_compose_images_dir="$docker_compose_dir/images"
docker_compose_file="$docker_compose_dir/docker-compose.yml"
docker_compose_images_readme_file="$docker_compose_images_dir/readme.txt"
podman_storage_config="/etc/containers/storage.conf"

podman_rw_storage=/user/var/lib/containers/storage
docker_compose_monit_file=/etc/monit.d/docker-compose
monit_bin=/usr/bin/monit
skopeo_bin=/usr/sbin/skopeo
docker_compose_images_cache_dir="/user/etc/docker-compose/.images-cache"

swapfile="$user_fs_mount/swapfile"

var_log_dir="/var/log"
user_var_log_dir="$user_fs_mount$var_log_dir"

nm_system_connections_dir="/etc/NetworkManager/system-connections"
user_nm_system_connections_dir="$user_fs_mount/etc/enapter/nm-system-connections"

install_bundle_name="install.raucb"
