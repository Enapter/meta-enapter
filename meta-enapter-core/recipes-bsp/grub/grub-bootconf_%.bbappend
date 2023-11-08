FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://grub.cfg \
           "

do_install() {
    install -d ${D}${EFI_FILES_PATH}
    install -m 0644 ${WORKDIR}/grub.cfg ${D}${EFI_FILES_PATH}/grub.cfg
}
