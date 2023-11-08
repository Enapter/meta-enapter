FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://chronyd.env"

SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_install:append() {
    install -d ${D}${sysconfdir}/default
    install -m 0644 ${WORKDIR}/chronyd.env ${D}${sysconfdir}/default/chronyd

    sed -i '/ConditionCapability=CAP_SYS_TIME/a ConditionFileNotEmpty=/etc/chrony.conf' ${D}${systemd_unitdir}/system/chronyd.service
}
