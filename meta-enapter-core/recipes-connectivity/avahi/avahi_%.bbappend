FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://avahi-daemon.conf \
            file://http.service \
           "

do_install:append() {
    install -m 0644 ${WORKDIR}/avahi-daemon.conf ${D}/etc/avahi/avahi-daemon.conf
    install -m 0644 ${WORKDIR}/http.service ${D}/etc/avahi/services/http.service
}

FILES:${PN} += " \
        /etc/avahi/services/http.service \
"
