FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://grub.cfg \
            file://grub.cfg.install \
           "

do_install() {
    install -d ${D}${EFI_FILES_PATH}
    install -m 0644 ${WORKDIR}/grub.cfg ${D}${EFI_FILES_PATH}
    install -m 0644 ${WORKDIR}/grub.cfg.install ${D}${EFI_FILES_PATH}
}

FILES:${PN} += "\
                ${EFI_FILES_PATH}/grub.cfg.install \
               "
