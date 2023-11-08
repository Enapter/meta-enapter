SUMMARY = "Enapter Journald Persistence Setup"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

SRC_URI = "file://LICENSE \
           file://${BPN}.service \
           file://${BPN}.sh \
           file://var-log-journal.mount \
          "

RDEPENDS:${PN} = "bash"

inherit systemd

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} = "${PN}.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_install() {
    install -d ${D}/${bindir}
    install -m 0755 ${WORKDIR}/${PN}.sh ${D}${bindir}/${PN}

    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/${PN}.service ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/var-log-journal.mount ${D}${systemd_unitdir}/system/
}

FILES:${PN} += " \
        ${systemd_unitdir}/system/${PN}.service \
        ${bindir}/${PN} \
        ${systemd_unitdir}/system/var-log-journal.mount \
"

