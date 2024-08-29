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

SRCREV_machine = "037d55485563d2750f9d64f8ad6c499b15abf518"
SRCREV_meta = "694e046ff4449d031f51c2e85f5dff035f5fa9e9"
LINUX_VERSION = "6.6.47"
LINUX_VERSION_EXTENSION = "-enapter"

MODSIGN_PRIVKEY = "${SECURE_BOOT_SIGNING_KEY}"
MODSIGN_X509 = "${SECURE_BOOT_SIGNING_CERT}"
