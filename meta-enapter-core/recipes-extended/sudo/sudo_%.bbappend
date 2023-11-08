FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://enapter"

do_install:append() {
    install -d ${D}${sysconfdir}/sudoers.d
    install -m 0644 ${WORKDIR}/enapter ${D}/${sysconfdir}/sudoers.d/enapter
}

FILES:${PN} += " \
    ${sysconfdir}/sudoers.d/enapter \
"
