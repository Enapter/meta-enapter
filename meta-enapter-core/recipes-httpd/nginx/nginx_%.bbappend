FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

PACKAGECONFIG = "ssl http-auth-request"

do_install:append() {
    rm -rf ${D}${sysconfdir}/nginx/nginx.conf
}
