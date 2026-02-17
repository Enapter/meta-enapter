FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

require recipes-kernel/linux/linux-yocto-enapter.inc

SRCREV_machine = "dbcb8d8e4163e46066f43e2bd9a6779e594ec900"
SRCREV_meta = "d2387ec7cf374ccffe480f7a00102f46b990d529"
LINUX_VERSION = "6.6.100"
