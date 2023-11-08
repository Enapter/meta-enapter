FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://0002-Podman-should-listen-for-tcp-socket-instead-unix-dom.patch \
    file://containers.conf \
    file://podman.json \
"

SYSTEMD_SERVICE:${PN} = "podman.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_install:append() {
    install ${WORKDIR}/containers.conf ${D}/${sysconfdir}/containers/containers.conf

    rm ${D}${systemd_unitdir}/system/podman.socket
    rm ${D}${systemd_unitdir}/user/podman.socket

    mkdir -p ${D}/${sysconfdir}/containers/networks
    install ${WORKDIR}/podman.json ${D}/${sysconfdir}/containers/networks/podman.json
}
