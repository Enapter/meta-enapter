SUMMARY = "vimrc file for enapter user"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

SRC_URI = "file://LICENSE \
           file://enapter_vimrc \
           file://enapter_bash_profile \
           file://enapter_bashrc \
           file://enapter-aliases.sh \
          "

inherit useradd

ENAPTER_USERNAME ?= "enapter"
# default password is "enapter", can be changed and persisted via "enapter-set-password" script
ENAPTER_USER_PASSWD_HASH ?= "\$6\$6eb82457686bad72\$FrAewCqMTY5cu/9neeZTFDJDFopeprTE7bo2Fui4b.x83uOL8Qqs4xGhFeJbyWlGbxHWOvCSOxe8pghZiUIgt1"

RDEPENDS:${PN} += "bash"

USERADD_PACKAGES = "${PN}"
USERADD_PARAM:${PN} = " \
    --uid 1000 \
    --home /home/${ENAPTER_USERNAME} \
    --no-user-group \
    --groups sudo \
    --password '${ENAPTER_USER_PASSWD_HASH}' \
    --system --no-create-home \
    --shell /bin/bash \
    ${ENAPTER_USERNAME}"

do_install() {
    install -d ${D}/home/${ENAPTER_USERNAME}
    install -d ${D}/home/${ENAPTER_USERNAME}/.vim
    install -d ${D}/home/${ENAPTER_USERNAME}/.vim/backup
    install -d ${D}/home/${ENAPTER_USERNAME}/.vim/undo
    install -d ${D}/home/${ENAPTER_USERNAME}/.vim/swap

    install -m 0644 ${WORKDIR}/enapter_vimrc ${D}/home/${ENAPTER_USERNAME}/.vimrc
    install -m 0644 ${WORKDIR}/enapter_bashrc ${D}/home/${ENAPTER_USERNAME}/.bashrc
    sed -i -e 's|@@ENAPTER_USERNAME@@|${ENAPTER_USERNAME}|' ${D}/home/${ENAPTER_USERNAME}/.bashrc
    install -m 0644 ${WORKDIR}/enapter_bash_profile ${D}/home/${ENAPTER_USERNAME}/.bash_profile
    sed -i -e 's|@@ENAPTER_USERNAME@@|${ENAPTER_USERNAME}|' ${D}/home/${ENAPTER_USERNAME}/.bash_profile

    chown ${ENAPTER_USERNAME} -R ${D}/home/${ENAPTER_USERNAME}

    install -d ${D}/root
    install -d ${D}/root/.vim
    install -d ${D}/root/.vim/backup
    install -d ${D}/root/.vim/undo
    install -d ${D}/root/.vim/swap

    install -m 0644 ${WORKDIR}/enapter_vimrc ${D}/root/.vimrc
    install -m 0644 ${WORKDIR}/enapter_bashrc ${D}/root/.bashrc
    sed -i -e 's|@@ENAPTER_USERNAME@@|${ENAPTER_USERNAME}|' ${D}/root/.bashrc
    install -m 0644 ${WORKDIR}/enapter_bash_profile ${D}/root/.bash_profile
    sed -i -e 's|@@ENAPTER_USERNAME@@|${ENAPTER_USERNAME}|' ${D}/root/.bash_profile

    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/enapter-aliases.sh ${D}${bindir}/enapter-aliases
    sed -i -e 's|@@ENAPTER_USERNAME@@|${ENAPTER_USERNAME}|' ${D}${bindir}/enapter-aliases
}

FILES:${PN} += " \
    /home/${ENAPTER_USERNAME}/.bashrc \
    /home/${ENAPTER_USERNAME}/.bash_profile \
    /home/${ENAPTER_USERNAME}/.vimrc \
    /home/${ENAPTER_USERNAME}/.vim \
    /home/${ENAPTER_USERNAME}/.vim/backup \
    /home/${ENAPTER_USERNAME}/.vim/undo \
    /home/${ENAPTER_USERNAME}/.vim/swap \
    /root/.bashrc \
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
