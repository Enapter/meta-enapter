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

SIGN_AFTER ?= "do_compile"
SIGN_BEFORE ?= "do_deploy"

# This function is copied from meta-intel layer classes/uefi-sign.bbclas file and licensed under MIT
# Copyright Intel
#
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), to deal 
# in the Software without restriction, including without limitation the rights 
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
# THE SOFTWARE.
python () {
    import os
    import hashlib

    if d.getVar('SECURE_BOOT_SIGNING_CERT') != None and d.getVar('SECURE_BOOT_SIGNING_KEY') != None:
        for varname in ('SECURE_BOOT_SIGNING_CERT', 'SECURE_BOOT_SIGNING_KEY'):
            filename = d.getVar(varname)
            if filename is None:
                bb.fatal('%s is not set.' % varname)
            if not os.path.isfile(filename):
                bb.fatal('%s=%s is not a file.' % (varname, filename))
            with open(filename, 'rb') as f:
                data = f.read()
            hash = hashlib.sha256(data).hexdigest()
            d.setVar('%s_HASH' % varname, hash)

            # Must reparse and thus rehash on file changes.
            bb.parse.mark_dependency(d, filename)

        bb.build.addtask('uefi_sign', d.getVar('SIGN_BEFORE'), d.getVar('SIGN_AFTER'), d)

        # Original binary needs to be regenerated if the hash changes since we overwrite it
        # SIGN_AFTER isn't necessarily when it gets generated, but its our best guess
        d.appendVarFlag(d.getVar('SIGN_AFTER'), 'vardeps', 'SECURE_BOOT_SIGNING_CERT_HASH SECURE_BOOT_SIGNING_KEY_HASH')
}

do_uefi_sign() {
    if [ -f ${SECURE_BOOT_SIGNING_KEY} ] && [ -f ${SECURE_BOOT_SIGNING_CERT} ]; then
        for i in `find ${SIGNING_DIR}/ -name '${SIGNING_BINARIES}'`; do
            sbsign --key ${SECURE_BOOT_SIGNING_KEY} --cert ${SECURE_BOOT_SIGNING_CERT} $i
            sbverify --cert ${SECURE_BOOT_SIGNING_CERT} $i.signed
            mv $i.signed $i
        done
    fi
}

do_uefi_sign[depends] += "sbsigntool-native:do_populate_sysroot"

do_uefi_sign[vardeps] += "SECURE_BOOT_SIGNING_CERT_HASH \
                          SECURE_BOOT_SIGNING_KEY_HASH  \
                          SIGN_BEFORE SIGN_AFTER        \
                         "

SRCREV_machine = "32c9cdbe383c153af23cfa1df0a352b97ab3df7a"
SRCREV_meta = "0553e01ca003e82d32d9b85c0275568e8ce67274"
LINUX_VERSION = "6.1.60"
LINUX_VERSION_EXTENSION = "-enapter"

MODSIGN_PRIVKEY = "${SECURE_BOOT_SIGNING_KEY}"
MODSIGN_X509 = "${SECURE_BOOT_SIGNING_CERT}"
