# SPDX-License-Identifier: Apache-2.0 AND MIT
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://can.cfg \
    file://cdc_mbim.cfg \
    file://eth.cfg \
    file://f81801_support.cfg \
    file://hardening.cfg \
    file://i2c_smbus.cfg \
    file://iwlwifi_debug.cfg \
    file://minimal_debug.cfg \
    file://module_sig_format.cfg \
    file://no_debug_info.cfg \
    file://squashfs.cfg \
    file://usb_wwan.cfg \
    file://wifi.cfg \
    "

KERNEL_EXTRA_FEATURES = "\
                         features/ftrace/ftrace-function-tracer-disable.scc \
                         features/i2c/i2cdbg.scc \
                         features/ima/modsign.scc \
                         features/mmc/mmc-realtek.scc \
                         features/netfilter/netfilter.scc \
                         features/ocicontainer/ocicontainer.scc \
                         features/security/security.scc \
                         features/usb/serial-all.scc \
                         features/wifi/wifi-usb.scc \
                         cfg/vmware-guest.scc \
                         \
                         can.cfg \
                         cdc_mbim.cfg \
                         eth.cfg \
                         hardening.cfg \
                         i2c_smbus.cfg \
                         iwlwifi_debug.cfg \
                         minimal_debug.cfg \
                         module_sig_format.cfg \
                         no_debug_info.cfg \
                         rauc.cfg \
                         squashfs.cfg \
                         usb_wwan.cfg \
                         wifi.cfg \
                        "

SIGNING_DIR ?= "${B}"
SIGNING_BINARIES ?= "bzImage"
SIGN_AFTER ?= "do_compile"
SIGN_BEFORE ?= "do_deploy"

# uefi-sign.bbclass defined in meta-intel layer
inherit uefi-sign

SRCREV_machine = "c2603c511feb427b2b09f74b57816a81272932a1"
SRCREV_meta = "2ad3db8c94fece927ad59267524d42ac6353b137"
LINUX_VERSION = "6.6.93"

# we should add distro version to kernel version to
# ensure that the module version information is
# sufficient to prevent loading a module into a different kernel
LINUX_VERSION_EXTENSION = "-enapter-${DISTRO_VERSION}"

inherit kernel-modsign

MODSIGN_PRIVKEY = "${MODSIGN_SIGNING_KEY}"
MODSIGN_X509 = "${MODSIGN_SIGNING_CERT}"
