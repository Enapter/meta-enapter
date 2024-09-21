FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "\
            file://99-rauc.rules \
            file://enapter-link-data-disk.sh \
            file://enapter-custom-grub-integration.sh \
           "

RDEPENDS:${PN} += "bash"

do_install:append() {
    install -d ${D}/${bindir}
    install -m 0755 ${WORKDIR}/enapter-link-data-disk.sh ${D}${bindir}/enapter-link-data-disk
    install -m 0755 ${WORKDIR}/enapter-custom-grub-integration.sh ${D}${bindir}/enapter-custom-grub-integration

    install -Dm 0644 ${WORKDIR}/99-rauc.rules ${D}${nonarch_base_libdir}/udev/rules.d/99-rauc.rules
}
