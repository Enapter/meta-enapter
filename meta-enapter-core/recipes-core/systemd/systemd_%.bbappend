FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://coredump.conf \
           "

RDEPENDS:${PN} = "bash"

do_install:append() {
    install -d ${D}/${sysconfdir}/systemd/coredump.conf.d
    install -m 0644 ${WORKDIR}/coredump.conf ${D}/${sysconfdir}/systemd/coredump.conf.d/01-enapter.conf
}
