SUMMARY = "System and process monitoring utilities"
SRC_URI += "file://60-enapter.conf"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

do_install:append() {
    install -d ${D}${sysconfdir}/sysctl.d
    install -m 0644 ${WORKDIR}/60-enapter.conf ${D}${sysconfdir}/sysctl.d/60-enapter.conf
}
