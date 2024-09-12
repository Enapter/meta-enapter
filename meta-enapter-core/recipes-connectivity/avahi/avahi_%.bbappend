FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://avahi-daemon.conf \
            file://http.service \
           "

do_install:append() {
    install -m 0644 ${WORKDIR}/avahi-daemon.conf ${D}${sysconfdir}/avahi/avahi-daemon.conf
    install -m 0644 ${WORKDIR}/http.service ${D}${sysconfdir}/avahi/services/http.service
}

FILES:${PN} += " \
        ${sysconfdir}/avahi/services/http.service \
"
