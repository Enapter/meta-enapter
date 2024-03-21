FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://dnsmasq.conf \
            file://resolv-conf.dnsmasq \
            file://dnsmasq.service \
           "

# dnsmasq dbus support required by NetworkManager dns plugin
PACKAGECONFIG = "dbus"

# we are not using resolveconf packageconfig option, because we are using openresolv instead
# PACKAGECONFIG += " resolveconf"

do_install:append(){
    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/dnsmasq.conf ${D}${sysconfdir}/dnsmasq.conf

    install -d ${D}${sysconfdir}/dnsmasq.d
    install -m 0644 ${WORKDIR}/resolv-conf.dnsmasq ${D}${sysconfdir}/resolv-conf.dnsmasq

    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/dnsmasq.service ${D}${systemd_unitdir}/system/dnsmasq.service
}
