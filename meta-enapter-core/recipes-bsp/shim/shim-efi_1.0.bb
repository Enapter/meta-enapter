SUMMARY = "shim is a trivial EFI application."
DESCRIPTION = "shim is a trivial EFI application that, when run, \
attempts to open and execute another application. It will initially \
attempt to do this via the standard EFI LoadImage() and StartImage() \
calls. If these fail (because secure boot is enabled and the binary \
is not signed with an appropriate key, for instance) it will then \
validate the binary against a built-in certificate. If this succeeds \
and if the binary or signing key are not blacklisted then shim will \
relocate and execute the binary."
HOMEPAGE = "https://github.com/rhboot/shim.git"
SECTION = "bootloaders"

LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${WORKDIR}/COPYRIGHT;md5=b92e63892681ee4e8d27e7a7e87ef2bc"

SRC_URI = "file://shim${EFI_ARCH}.efi.signed \
           file://mm${EFI_ARCH}.efi.signed \
           file://COPYRIGHT \
          "
# The EFI name for the architecture
EFI_ARCH ?= "INVALID"
EFI_ARCH:x86-64 = "x64"

# Location of EFI files inside EFI System Partition
EFIDIR ?= "/EFI/BOOT"

# Prefix where ESP is mounted inside rootfs. Set to empty if package is going
# to be installed to ESP directly
EFI_PREFIX ?= "/boot"

# Location inside rootfs.
EFI_FILES_PATH = "${EFI_PREFIX}${EFIDIR}"

do_install() {
    install -d ${D}${EFI_FILES_PATH}
    install -m 0644 ${WORKDIR}/shim${EFI_ARCH}.efi.signed ${D}${EFI_FILES_PATH}/boot${EFI_ARCH}.efi
    install -m 0644 ${WORKDIR}/mm${EFI_ARCH}.efi.signed ${D}${EFI_FILES_PATH}/mm${EFI_ARCH}.efi
}

FILES:${PN} += " \
    ${EFI_FILES_PATH}/boot${EFI_ARCH}.efi \
    ${EFI_FILES_PATH}/mm${EFI_ARCH}.efi \
"
