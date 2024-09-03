SUMMARY = "Enapter Login CLI"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

SRC_URI = " \
          file://LICENSE \
          file://enapter-login-cli.sh \
          file://enapter-login-cli@.service \
          file://enapter-show-ip-address.sh \
          "

RDEPENDS:${PN} = "bash rlwrap"

inherit systemd

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} = "enapter-login-cli@.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_install() {
    install -d ${D}/${sbindir}
    install -m 0755 ${WORKDIR}/enapter-login-cli.sh ${D}${sbindir}/enapter-login-cli

    install -d ${D}/${bindir}
    install -m 0755 ${WORKDIR}/enapter-show-ip-address.sh ${D}${bindir}/enapter-show-ip-address

    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/enapter-login-cli@.service ${D}${systemd_unitdir}/system
}
