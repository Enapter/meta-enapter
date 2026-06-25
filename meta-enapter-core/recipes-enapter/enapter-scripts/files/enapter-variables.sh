# Helper shell variables
#
# SPDX-FileCopyrightText: 2024 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

rootfs_patch_script="patch_rootfs.sh"

disk_app_a_label="enp-app-a"
disk_app_b_label="enp-app-b"
disk_backup_label="enp-backup"
disk_bootloader_label="enp-boot"
disk_config_label="enp-config"
disk_data_label="enp-data3"
disk_data_reset_label="enp-data3-rst"
disk_export_label="enp-export"
disk_images_label="enp-images3"
disk_kernel_a_label="enp-kernel-a"
disk_kernel_b_label="enp-kernel-b"
disk_legacy_boot_label="enp-os"
disk_legacy_data_label="enp-data-disk"
disk_legacy_data_reset_label="enp-data-reset"
disk_root_a_label="enp-root-a"
disk_root_b_label="enp-root-b"
disk_usb_boot_label="enp-os-usb"

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
cloud_etc_dir="$etc_enapter/cloud"
cloud_init_env_file="$cloud_etc_dir/cloud-init.env"
imds_base_url="http://169.254.169.254/latest"
sshd_config_dir="/etc/ssh/sshd_config.d"
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

set_userspace_disk_pre_wipe_script="/usr/bin/enapter-set-userspace-disk-pre-wipe"
set_userspace_disk_pre_part_script="/usr/bin/enapter-set-userspace-disk-pre-part"
set_userspace_disk_pre_fs_script="/usr/bin/enapter-set-userspace-disk-pre-fs"
set_userspace_disk_post_script="/usr/bin/enapter-set-userspace-disk-post"

min_data_disk_size_bytes=64424509440 # 60.00 GiB

nginx_conf_path=/etc/nginx/nginx.conf

user_nginx_ssl_cert="$user_fs_mount/etc/enapter/certs/nginx/cert.pem"
user_nginx_ssl_certkey="$user_fs_mount/etc/enapter/certs/nginx/certkey.pem"

pre_install_boot_nginx_ssl_cert_file="pre_install_boot_nginx_cert.pem"
pre_install_boot_nginx_ssl_certkey_file="pre_install_boot_nginx_certkey.pem"
pre_install_boot_gateway_setup_env_file="enapter-gateway-setup.env"
pre_install_boot_nginx_ssl_cert_tmp="/root/$pre_install_boot_nginx_ssl_cert_file"
pre_install_boot_nginx_ssl_certkey_tmp="/root/$pre_install_boot_nginx_ssl_certkey_file"
pre_install_boot_nginx_ssl_cert_config="$config_mount/$pre_install_boot_nginx_ssl_cert_file"
pre_install_boot_nginx_ssl_certkey_config="$config_mount/$pre_install_boot_nginx_ssl_certkey_file"
pre_install_boot_gateway_setup_env_tmp="/root/$pre_install_boot_gateway_setup_env_file"
pre_install_boot_gateway_setup_env_config="$config_mount/$pre_install_boot_gateway_setup_env_file"

user_gateway_setup_env="$user_fs_mount/etc/enapter/$pre_install_boot_gateway_setup_env_file"

hdd_backup_device="/dev/disk/by-partlabel/$disk_backup_label"
hdd_config_device="/dev/disk/by-partlabel/$disk_config_label"
hdd_data_device="/dev/disk/by-partlabel/$disk_data_label"
hdd_data_disk_device="/dev/data-disk"
# for soft reset we are using FS label and not partlabel
hdd_data_reset_device="/dev/disk/by-label/$disk_data_reset_label"
hdd_export_device="/dev/disk/by-partlabel/$disk_export_label"
hdd_images_device="/dev/disk/by-partlabel/$disk_images_label"
legacy_hdd_boot_device="/dev/disk/by-partlabel/$disk_legacy_boot_label"
legacy_hdd_data_device="/dev/disk/by-partlabel/$disk_legacy_data_label"
legacy_hdd_data_reset_device="/dev/disk/by-partlabel/$disk_legacy_data_reset_label"
usb_boot_device="/dev/disk/by-label/$disk_usb_boot_label"

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
