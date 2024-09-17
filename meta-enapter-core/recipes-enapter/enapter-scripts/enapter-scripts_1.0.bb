SUMMARY = "Enapter Scripts"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

SRC_URI = " \
          file://LICENSE \
          file://enapter-boot-fallback-enable.sh \
          file://enapter-boot-success.sh \
          file://enapter-check-installed.sh \
          file://enapter-functions.sh \
          file://enapter-linux-install.sh \
          file://enapter-linux-update.sh \
          file://enapter-perform-factory-reset.sh \
          file://enapter-reboot.sh \
          file://enapter-set-password.sh \
          file://enapter-set-userspace-disk.sh \
          file://enapter-shutdown.sh \
          file://enapter-variables.sh \
          file://enapter-wait-for-ports.sh \
          "

RDEPENDS:${PN} = "bash"

do_install() {
    install -d ${D}/${bindir}

    install -m 0755 ${WORKDIR}/enapter-boot-fallback-enable.sh ${D}${bindir}/enapter-boot-fallback-enable
    install -m 0755 ${WORKDIR}/enapter-boot-success.sh ${D}${bindir}/enapter-boot-success
    install -m 0755 ${WORKDIR}/enapter-check-installed.sh ${D}${bindir}/enapter-check-installed
    install -m 0755 ${WORKDIR}/enapter-linux-install.sh ${D}${bindir}/enapter-linux-install
    install -m 0755 ${WORKDIR}/enapter-linux-update.sh ${D}${bindir}/enapter-linux-update
    install -m 0755 ${WORKDIR}/enapter-perform-factory-reset.sh ${D}${bindir}/enapter-perform-factory-reset
    install -m 0755 ${WORKDIR}/enapter-reboot.sh ${D}${bindir}/enapter-reboot
    install -m 0755 ${WORKDIR}/enapter-set-password.sh ${D}${bindir}/enapter-set-password
    install -m 0755 ${WORKDIR}/enapter-set-userspace-disk.sh ${D}${bindir}/enapter-set-userspace-disk
    install -m 0755 ${WORKDIR}/enapter-shutdown.sh ${D}${bindir}/enapter-shutdown
    install -m 0755 ${WORKDIR}/enapter-wait-for-ports.sh ${D}${bindir}/enapter-wait-for-ports

    install -d ${D}${datadir}/scripts
    install -m 0755 ${WORKDIR}/enapter-functions.sh ${D}${datadir}/scripts/enapter-functions
    install -m 0755 ${WORKDIR}/enapter-variables.sh ${D}${datadir}/scripts/enapter-variables
}

FILES:${PN} += " \
    ${datadir}/scripts/enapter-functions \
    ${datadir}/scripts/enapter-variables \
    "
