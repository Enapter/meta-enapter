SUMMARY = "Enapter Custom Login"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

SRC_URI = " \
          file://LICENSE \
          file://enapter-login.sh \
          file://enapter-show-ip-address.sh \
          "

RDEPENDS:${PN} = "bash rlwrap"

do_install() {
    install -d ${D}/${sbindir}
    install -m 0755 ${WORKDIR}/enapter-login.sh ${D}${sbindir}/enapter-login

    install -d ${D}/${bindir}
    install -m 0755 ${WORKDIR}/enapter-show-ip-address.sh ${D}${bindir}/enapter-show-ip-address
}
