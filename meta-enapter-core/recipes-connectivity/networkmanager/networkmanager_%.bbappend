FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-Add-confirmation-dialog-on-connection-deactivation.patch \
            file://00-use-dnsmasq.conf \
            file://01-autoconnect-retries.conf \
            file://00-podman.conf \
            file://01-add-hosts.conf \
            file://02-cache.conf \
           "

PACKAGECONFIG:append = " modemmanager ppp man-resolv-conf"

do_install:append(){
    install -d ${D}${sysconfdir}/NetworkManager/conf.d/
    install -m 0644 ${WORKDIR}/00-use-dnsmasq.conf ${D}${sysconfdir}/NetworkManager/conf.d/
    install -m 0644 ${WORKDIR}/01-autoconnect-retries.conf ${D}${sysconfdir}/NetworkManager/conf.d/

    install -d ${D}${sysconfdir}/NetworkManager/dnsmasq.d/
    install -m 0644 ${WORKDIR}/00-podman.conf ${D}${sysconfdir}/NetworkManager/dnsmasq.d/
    install -m 0644 ${WORKDIR}/01-add-hosts.conf ${D}${sysconfdir}/NetworkManager/dnsmasq.d/
    install -m 0644 ${WORKDIR}/02-cache.conf ${D}${sysconfdir}/NetworkManager/dnsmasq.d/
}
