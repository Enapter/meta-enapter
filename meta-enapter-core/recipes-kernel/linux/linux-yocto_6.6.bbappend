# SPDX-License-Identifier: Apache-2.0 AND MIT
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://squashfs.cfg \
    file://can.cfg \
    file://iwlwifi_debug.cfg \
    file://no_debug_info.cfg \
    file://f81801_support.cfg \
    file://usb_wwan.cfg \
    file://cdc_mbim.cfg \
    file://i2c_smbus.cfg \
    "

KERNEL_EXTRA_FEATURES = "features/netfilter/netfilter.scc \
                         features/taskstats/taskstats.scc \
                         features/wifi/wifi-usb.scc \
                         features/kexec/kexec-enable.scc \
                         features/usb/serial-all.scc \
                         features/security/security.scc \
                         features/mmc/mmc-realtek.scc \
                         features/ocicontainer/ocicontainer.scc \
                         features/i2c/i2cdbg.scc \
                         cfg/vmware-guest.scc \
                         squashfs.cfg \
                         can.cfg \
                         iwlwifi_debug.cfg \
                         no_debug_info.cfg \
                         usb_wwan.cfg \
                         cdc_mbim.cfg \
                         i2c_smbus.cfg \
                        "

SIGNING_DIR ?= "${B}"
SIGNING_BINARIES ?= "bzImage"
SIGN_AFTER ?= "do_compile"
SIGN_BEFORE ?= "do_deploy"

# uefi-sign.bbclass defined in meta-intel layer
inherit uefi-sign

SRCREV_machine = "91de249b6804473d49984030836381c3b9b3cfb0"
SRCREV_meta = "112c053ae46d21e6e8d4bd347f311bb7e803f384"
LINUX_VERSION = "6.6.32"
LINUX_VERSION_EXTENSION = "-enapter"

MODSIGN_PRIVKEY = "${SECURE_BOOT_SIGNING_KEY}"
MODSIGN_X509 = "${SECURE_BOOT_SIGNING_CERT}"
