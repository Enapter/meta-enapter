FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://cfg \
                   file://sbat.csv \
                   file://0001-Commands-to-increment-and-decrement-variables.patch \
                   file://0002-Implement-search_part_label.patch \
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
        echo \
        efi_gop \
        ext2 \
        fat \
        gpt \
        help \
        increment \
        linux \
        loadenv \
        ls \
        normal \
        part_gpt \
        part_msdos \
        probe \
        read \
        reboot \
        search \
        search_fs_file \
        search_fs_uuid \
        search_label \
        search_part_label \
        sleep \
        test \
        true \
    "

    grub-mkimage -v -c ../cfg -p ${EFIDIR} -d ./grub-core/ \
                 --sbat ${WORKDIR}/sbat.csv \
                 -O ${GRUB_TARGET}-efi -o ./${GRUB_IMAGE_PREFIX}${GRUB_IMAGE} \
                 ${GRUB_MODULES}

    grub-editenv ${WORKDIR}/grubenv create
}

SIGNING_DIR ?= "${B}"
SIGNING_BINARIES ?= "*.efi"
SIGN_AFTER ?= "do_compile"
SIGN_BEFORE ?= "do_install"

# uefi-sign.bbclass defined in meta-intel layer
inherit uefi-sign

FILES:${PN} += "${EFI_FILES_PATH}/grubenv \
               "
