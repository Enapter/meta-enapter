FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://rootfs \
            file://init \
            file://finish \
            file://enapter-variables.sh \
            file://hddrootfs \
"

do_install:append() {
    install -d ${D}${datadir}/scripts
    install -m 0755 ${WORKDIR}/enapter-variables.sh ${D}${datadir}/scripts/enapter-variables

    install -m 0755 ${WORKDIR}/hddrootfs ${D}/init.d/91-hddrootfs
}

FILES:${PN}-base += " \
    ${datadir}/scripts/enapter-variables \
    "

FILES:initramfs-module-rootfs += " \
    /init.d/91-hddrootfs \
    "
