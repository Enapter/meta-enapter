SUMMARY = "Enapter System Banner"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

SRC_URI = " \
          file://LICENSE \
          file://enapter-banner.service \
          file://enapter-set-banner.sh \
          "

RDEPENDS:${PN} = "bash"

inherit systemd

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} = "${PN}.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_install() {
    install -d ${D}/${bindir}
    install -m 0755 ${WORKDIR}/enapter-set-banner.sh ${D}${bindir}/enapter-set-banner

    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/${PN}.service ${D}${systemd_unitdir}/system
}
