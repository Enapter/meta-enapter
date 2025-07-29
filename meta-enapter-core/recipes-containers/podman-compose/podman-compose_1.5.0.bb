DESCRIPTION = "An implementation of docker-compose with podman backend"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b234ee4d69f5fce4486a80fdaf4a4263"

SRC_URI = "git://github.com/containers/podman-compose.git;branch=main;protocol=https"

SRCREV = "f7eeda1a3db10952424af6a5b0501c269ebe3f0d"

S = "${WORKDIR}/git"

RDEPENDS:${PN} += "\
    python3-core \
    python3-asyncio \
    python3-dotenv \
    python3-json \
    python3-pyyaml \
    python3-unixadmin \
"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/podman_compose.py ${D}${bindir}/podman-compose
}

FILES:${PN} = "${bindir}/podman-compose"
