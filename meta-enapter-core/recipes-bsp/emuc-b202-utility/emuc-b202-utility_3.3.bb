SUMMARY = "Innodisk EMUC-B202 CAN interface daemon utility"
DESCRIPTION = "${SUMMARY}"
LICENSE = "GPL-2.0-only"
HOMEPAGE = "https://www.innodisk.com/en/products/embedded-peripheral/communication/emuc-b202#tab4"
LIC_FILES_CHKSUM = "file://main.c;beginline=6;endline=14;md5=89ff91d940b4bc09b6de0300b34a888f"

inherit autotools-brokensep

SRCREV = "59f37f31c801d48194a03b636108816910b1cacd"
SRC_URI = "git://github.com/Enapter/emuc-b202-utility.git;protocol=https;branch=master \
           "

S = "${WORKDIR}/git"

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 emucd ${D}${sbindir}/emucd
}
