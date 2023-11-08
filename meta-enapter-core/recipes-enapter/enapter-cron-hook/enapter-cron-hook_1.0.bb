SUMMARY = "Enapter Cron Hook Service"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

SRC_URI = " \
          file://LICENSE \
          file://${BPN}.service \
          file://${BPN}.timer \
          "

inherit systemd

PACKAGES = "${PN} ${PN}-timer"

SYSTEMD_PACKAGES = "${PN} ${PN}-timer"
SYSTEMD_SERVICE:${PN} = "${PN}.service"
SYSTEMD_AUTO_ENABLE:${PN} = "disable"
SYSTEMD_SERVICE:${PN}-timer = "${PN}.timer"
SYSTEMD_AUTO_ENABLE:${PN}-timer = "enable"

RDEPENDS:${PN} += " \
    bash \
"

do_install() {
    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/${PN}.service ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/${PN}.timer ${D}${systemd_unitdir}/system
}

FILES:${PN} += " \
        ${systemd_unitdir}/system/${PN}.service \
"

FILES:${PN}-timer += " \
        ${systemd_unitdir}/system/${PN}.timer \
"
