FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://password-reset \
            file://rootfs \
            file://init \
            file://finish \
"

do_install:append() {
    install -m 0755 ${WORKDIR}/password-reset ${D}/init.d/20-passwordreset
}

FILES:initramfs-module-password-reset += " \
    /init.d/20-passwordreset \
    "

PACKAGES += "initramfs-module-password-reset \
            "
