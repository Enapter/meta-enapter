FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-Add-confirmation-dialog-on-connection-deactivation.patch \
            file://00-resolvconf.conf \
            file://01-autoconnect-retries.conf \
            file://resolv.conf \
           "

PACKAGECONFIG[resolvconf] = "-Dresolvconf=${sbindir}/resolvconf,-Dresolvconf=no,,openresolv"
PACKAGECONFIG:append = " modemmanager ppp resolvconf"

do_install:append(){
    install -d ${D}${sysconfdir}/NetworkManager/conf.d/
    install -m 0644 ${WORKDIR}/00-resolvconf.conf ${D}${sysconfdir}/NetworkManager/conf.d/
    install -m 0644 ${WORKDIR}/01-autoconnect-retries.conf ${D}${sysconfdir}/NetworkManager/conf.d/

    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/resolv.conf ${D}${sysconfdir}/resolv.conf
}
