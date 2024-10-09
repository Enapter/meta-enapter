FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://enapter"

ENAPTER_USERNAME ?= "enapter"

do_install:append() {
    install -d ${D}${sysconfdir}/sudoers.d
    install -m 0644 ${WORKDIR}/enapter ${D}${sysconfdir}/sudoers.d/${ENAPTER_USERNAME}
    sed -i -e 's|@@ENAPTER_USERNAME@@|${ENAPTER_USERNAME}|' ${D}${sysconfdir}/sudoers.d/${ENAPTER_USERNAME}
}

FILES:${PN} += " \
    ${sysconfdir}/sudoers.d/${ENAPTER_USERNAME} \
"
