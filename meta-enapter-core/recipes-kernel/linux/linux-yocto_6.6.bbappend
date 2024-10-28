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
    file://hardening.cfg \
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
                         features/module-signing/force-signing.scc \
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
                         hardening.cfg \
                        "

SIGNING_DIR ?= "${B}"
SIGNING_BINARIES ?= "bzImage"
SIGN_AFTER ?= "do_compile"
SIGN_BEFORE ?= "do_deploy"

# uefi-sign.bbclass defined in meta-intel layer
inherit uefi-sign

SRCREV_machine = "18916a684a8b836957df88438f9bca590799d04c"
SRCREV_meta = "b1108273b878547b3d3281f21aba44a8c41ca741"
LINUX_VERSION = "6.6.58"

# we should add distro version to kernel version to
# ensure that the module version information is
# sufficient to prevent loading a module into a different kernel
LINUX_VERSION_EXTENSION = "-enapter-${DISTRO_VERSION}"

inherit kernel-modsign

MODSIGN_PRIVKEY = "${MODSIGN_SIGNING_KEY}"
MODSIGN_X509 = "${MODSIGN_SIGNING_CERT}"
