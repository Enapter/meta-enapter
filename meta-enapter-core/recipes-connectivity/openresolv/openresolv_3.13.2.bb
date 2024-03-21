DESCRIPTION = "openresolv is a management framework for resolv.conf"
HOMEPAGE = "https://github.com/NetworkConfiguration/openresolv"
SECTION = "net"
LICENSE = "BSD-2-Clause"

S = "${WORKDIR}/openresolv-3.13.2"
LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=b612f9979838f6126283eec15dfadb86"

SRC_URI = "https://github.com/NetworkConfiguration/openresolv/releases/download/v3.13.2/openresolv-3.13.2.tar.xz \
           file://resolvconf.conf \
          "

SRC_URI[sha256sum] = "36b5bcbe257a940c884f0d74321a47407baabab9e265e38859851c8311f6f0b0"

do_compile() {
    oe_runmake LIBEXECDIR=${libexecdir}/resolvconf
}

do_install() {
    oe_runmake DESTDIR=${D} SBINDIR=${sbindir} LIBEXECDIR=${libexecdir}/resolvconf proginstall

    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/resolvconf.conf ${D}${sysconfdir}/resolvconf.conf
}

FILES:${PN} += "${sbindir}/resolvconf \
                ${libexecdir}/resolvconf/libc \
                ${libexecdir}/resolvconf/dnsmasq \
                ${libexecdir}/resolvconf/named \
                ${libexecdir}/resolvconf/pdnsd \
                ${libexecdir}/resolvconf/pdns_recursor \
                ${libexecdir}/resolvconf/unbound \
                ${libexecdir}/resolvconf/libc.d \
                ${libexecdir}/resolvconf/libc.d/avahi-daemon \
                ${libexecdir}/resolvconf/libc.d/mdnsd \
               "
