FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://cfg \
                   file://sbat.csv \
                  "

DEPENDS:append = " sbsigntool-native"
RDEPENDS:${PN}:append = " bash"

PR = "enapter1"

do_preconfigure() {
    # Set version to value with revision (PR) part
    sed -i -e \
        "s/\(AC_INIT(\[GRUB\],\[\).*\(\],\[bug-grub@gnu.org\])\)/\1${PV}-${PR}\2/" \
        ${S}/configure.ac
}
addtask preconfigure after do_patch before do_configure

do_mkimage() {
    cd ${B}

    GRUB_MODULES="\
        boot \
        cat \
        echo \
        efifwsetup \
        efi_gop \
        ext2 \
        fat \
        help \
        hexdump \
        linux \
        loadenv \
        ls \
        normal \
        part_gpt \
        part_msdos \
        probe \
        read \
        reboot \
        regexp \
        search \
        search_fs_file \
        search_fs_uuid \
        search_label \
        serial \
        sleep \
        smbios \
        test \
        true \
    "

    grub-mkimage -v -c ../cfg -p ${EFIDIR} -d ./grub-core/ \
                 --sbat ${WORKDIR}/sbat.csv \
                 -O ${GRUB_TARGET}-efi -o ./${GRUB_IMAGE_PREFIX}${GRUB_IMAGE} \
                 ${GRUB_MODULES}

    grub-editenv ${WORKDIR}/grubenv create
}

do_install:append() {
    install -d ${D}${EFI_FILES_PATH}
    install -m 0644 ${WORKDIR}/grubenv ${D}${EFI_FILES_PATH}/grubenv
}

SIGNING_DIR ?= "${B}"
SIGNING_BINARIES ?= "*.efi"
SIGN_AFTER ?= "do_mkimage"
SIGN_BEFORE ?= "do_install"

# uefi-sign.bbclass defined in meta-intel layer
inherit uefi-sign

FILES:${PN} += "${EFI_FILES_PATH}/grubenv \
               "
