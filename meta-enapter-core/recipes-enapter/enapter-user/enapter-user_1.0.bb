SUMMARY = "vimrc file for enapter user"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

SRC_URI = "file://LICENSE \
           file://enapter_vimrc \
           file://enapter_bash_profile \
           file://enapter-aliases.sh \
          "

inherit useradd

RDEPENDS:${PN} += "bash"

# default password is "enapter", can be changed and persisted via "enapter-set-password" script
PASSWD = "\$6\$6eb82457686bad72\$FrAewCqMTY5cu/9neeZTFDJDFopeprTE7bo2Fui4b.x83uOL8Qqs4xGhFeJbyWlGbxHWOvCSOxe8pghZiUIgt1"
USERADD_PACKAGES = "${PN}"
USERADD_PARAM:${PN} = " \
    --uid 1000 \
    --home /home/enapter \
    --no-user-group \
    --groups sudo \
    --password '${PASSWD}' \
    --system --no-create-home \
    --shell /bin/bash \
    enapter"

do_install() {
    install -d ${D}/home/enapter
    install -d ${D}/home/enapter/.vim
    install -d ${D}/home/enapter/.vim/backup
    install -d ${D}/home/enapter/.vim/undo
    install -d ${D}/home/enapter/.vim/swap

    install -m 0644 ${WORKDIR}/enapter_vimrc ${D}/home/enapter/.vimrc
    install -m 0644 ${WORKDIR}/enapter_bash_profile ${D}/home/enapter/.bash_profile

    chown enapter -R ${D}/home/enapter

    install -d ${D}/root
    install -d ${D}/root/.vim
    install -d ${D}/root/.vim/backup
    install -d ${D}/root/.vim/undo
    install -d ${D}/root/.vim/swap

    install -m 0644 ${WORKDIR}/enapter_vimrc ${D}/root/.vimrc
    install -m 0644 ${WORKDIR}/enapter_bash_profile ${D}/root/.bash_profile

    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/enapter-aliases.sh ${D}${bindir}/enapter-aliases
}

FILES:${PN} += " \
    /home/enapter/.bash_profile \
    /home/enapter/.vimrc \
    /home/enapter/.vim \
    /home/enapter/.vim/backup \
    /home/enapter/.vim/undo \
    /home/enapter/.vim/swap \
    /root/.bash_profile \
    /root/.vimrc \
    /root/.vim \
    /root/.vim/backup \
    /root/.vim/undo \
    /root/.vim/swap \
"

# Prevents do_package failures with:
# debugsources.list: No such file or directory:
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
