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
    file://module_sig_format.cfg \
    file://eth.cfg \
    file://wifi.cfg \
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
                         features/ima/modsign.scc \
                         cfg/vmware-guest.scc \
                         squashfs.cfg \
                         can.cfg \
                         iwlwifi_debug.cfg \
                         no_debug_info.cfg \
                         usb_wwan.cfg \
                         cdc_mbim.cfg \
                         i2c_smbus.cfg \
                         module_sig_format.cfg \
                         wifi.cfg \
                         eth.cfg \
                        "

SIGNING_DIR ?= "${B}"
SIGNING_BINARIES ?= "bzImage"
SIGN_AFTER ?= "do_compile"
SIGN_BEFORE ?= "do_deploy"

# uefi-sign.bbclass defined in meta-intel layer
inherit uefi-sign

SRCREV_machine = "fb2635ac69abac0060cc2be2873dc4f524f12e66"
SRCREV_meta = "d26f4f3307216e06ee0b74fa9b57b17fba72a988"
LINUX_VERSION = "6.1.62"
LINUX_VERSION_EXTENSION = "-enapter"

inherit ${@bb.utils.contains('DISTRO_FEATURES', 'modsign', 'kernel-modsign', '', d)}

MODSIGN_PRIVKEY = "${SECURE_BOOT_SIGNING_KEY}"
MODSIGN_X509 = "${SECURE_BOOT_SIGNING_CERT}"
