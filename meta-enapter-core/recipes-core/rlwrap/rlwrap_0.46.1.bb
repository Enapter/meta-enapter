SUMMARY = "Readline wrapper"
DESCRIPTION = "rlwrap is a 'readline wrapper', a small utility that uses the GNU Readline library to allow the editing of keyboard input for any command."

HOMEPAGE = "https://github.com/hanslub42/rlwrap"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/COPYING;md5=94d55d512a9ba36caa9b7df079bae19f"

FILESEXTRAPATHS:append := "${THISDIR}/files:"

SRC_URI = "git://github.com/hanslub42/rlwrap.git;protocol=https;nobranch=1 \
           file://0001-Do-not-build-filters-and-docs.patch \
          "
SRCREV = "8c7086dd2385bb307cdadb893f2566b4e8da8ad9"

DEPENDS += " readline"
S = "${WORKDIR}/git"

inherit autotools-brokensep

do_configure:prepend() {
    autoreconf --verbose --install
    oe_runconf
    exit
}

do_install:append() {
}
