SUMMARY = "Enapter Init services"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

SRC_URI = " \
          file://LICENSE \
          file://enapter-init-sethostname.sh \
          file://enapter-init-sethostname.service \
          file://enapter-init-mount-fs.sh \
          file://enapter-init-mount-fs.service \
          file://enapter-init-mkswap.sh \
          file://enapter-init-mkswap.service \
          "

PACKAGES = "${PN}"
RDEPENDS:${PN} = "bash efibootmgr util-linux-blkid"

inherit systemd

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN}="enapter-init-sethostname.service enapter-init-mount-fs.service enapter-init-mkswap.service"
SYSTEMD_AUTO_ENABLE:${PN}="enable"

do_install() {
  install -d ${D}/${sbindir}
  install -m 0755 ${WORKDIR}/enapter-init-sethostname.sh ${D}/${sbindir}/enapter-init-sethostname
  install -m 0755 ${WORKDIR}/enapter-init-mount-fs.sh ${D}/${sbindir}/enapter-init-mount-fs
  install -m 0755 ${WORKDIR}/enapter-init-mkswap.sh ${D}/${sbindir}/enapter-init-mkswap

  install -d ${D}${systemd_unitdir}/system/
  install -m 0644 ${WORKDIR}/*.service ${D}${systemd_unitdir}/system/
}
