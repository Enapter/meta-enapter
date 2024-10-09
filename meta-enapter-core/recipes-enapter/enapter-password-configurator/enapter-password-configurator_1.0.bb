SUMMARY = "Enapter Password Configurator service"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

SRC_URI = " \
          file://LICENSE \
          file://${BPN}.service \
          "

ENAPTER_USERNAME ?= "enapter"

inherit systemd

SYSTEMD_SERVICE:${PN} = "${PN}.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

RDEPENDS:${PN} = "bash"

do_install() {
    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/${PN}.service ${D}${systemd_unitdir}/system
    sed -i -e 's|@@ENAPTER_USERNAME@@|${ENAPTER_USERNAME}|' ${D}${systemd_unitdir}/system/${PN}.service
}
