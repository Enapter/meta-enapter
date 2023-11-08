FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://limits.conf"

do_install:append() {
    install -d ${D}/${sysconfdir}/security
    install -m 0644 ${WORKDIR}/limits.conf ${D}/${sysconfdir}/security/limits.conf
}
