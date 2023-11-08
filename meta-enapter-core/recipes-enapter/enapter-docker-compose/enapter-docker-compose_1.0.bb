SUMMARY = "Enapter Podman Compose service"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

SRC_URI = " \
          file://LICENSE \
          file://${BPN}.service \
          file://${BPN}-pre.sh \
          file://${BPN}-post.sh \
          "

inherit systemd

SYSTEMD_SERVICE:${PN} = "${PN}.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

RDEPENDS:${PN} = "bash"

do_install() {
    install -d ${D}/${bindir}
    install -m 0755 ${WORKDIR}/${PN}-pre.sh ${D}${bindir}/${PN}-pre
    install -m 0755 ${WORKDIR}/${PN}-post.sh ${D}${bindir}/${PN}-post

    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/${PN}.service ${D}${systemd_unitdir}/system
}
