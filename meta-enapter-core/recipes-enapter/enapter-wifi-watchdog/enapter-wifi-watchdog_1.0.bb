SUMMARY = "Enapter WiFi Watchdog Service"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

SRC_URI = " \
          file://LICENSE \
          file://${BPN}.service \
          file://${BPN}.timer \
          file://${BPN}.sh \
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
    bc \
"

do_install() {
    install -d ${D}/${bindir}
    install -m 0755 ${WORKDIR}/${PN}.sh ${D}${bindir}/${PN}

    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/${PN}.service ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/${PN}.timer ${D}${systemd_unitdir}/system
}

FILES:${PN} += " \
        ${systemd_unitdir}/system/${PN}.service \
        ${bindir}/${PN} \
"

FILES:${PN}-timer += " \
        ${systemd_unitdir}/system/${PN}.timer \
"
