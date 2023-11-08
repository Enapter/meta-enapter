SUMMARY = "Innodisk EMUC-B201 Linux Kernel Module Driver"
DESCRIPTION="Linux kernel module driver for Innodisk EMUC-B201 CAN interface."
HOMEPAGE = "https://www.innodisk.com/en/products/embedded-peripheral/communication/emuc-b202#tab4"
LICENSE = "GPL-2.0-only"

LIC_FILES_CHKSUM = "file://LICENSE;md5=b234ee4d69f5fce4486a80fdaf4a4263"

DEPENDS = "virtual/kernel openssl-native"

SRCREV = "c45fa7012fd30d5719646115048a39823bb7d3f8"

SRC_URI = "git://github.com/Enapter/emuc-b202-lkm.git;protocol=https;branch=master \
           file://Makefile"

S = "${WORKDIR}/git"

inherit module kernel-module-split

MAKE_TARGETS = "modules"

MODULE_NAME = "emuc2socketcan"
MODULE_SIG_HASH ?= "sha256"

do_compile:prepend () {
    cp ${WORKDIR}/Makefile ${S}/Makefile
}

module_do_install() {
    # unplesant hack due to sign-file binary dynamically linked to libcrypto.so.3 inside
    # make-mod-script sysroot and not working after cleaning make-mod-scripts work dir
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${RECIPE_SYSROOT_NATIVE}/usr/lib \
    ${STAGING_KERNEL_BUILDDIR}/scripts/sign-file ${MODULE_SIG_HASH} ${SECURE_BOOT_SIGNING_KEY} ${SECURE_BOOT_SIGNING_CERT} ${MODULE_NAME}.ko

    install -d ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/${MODULE_NAME}
    install -m 0644 ${MODULE_NAME}.ko \
    ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/${MODULE_NAME}/${MODULE_NAME}.ko
}

RPROVIDES:${PN} += "kernel-module-emuc2socketcan"

COMPATIBLE_HOST = "(i.86|x86_64|arm|aarch64).*-linux"
