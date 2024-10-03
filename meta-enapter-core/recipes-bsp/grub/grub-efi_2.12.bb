require grub2.inc

# Location of EFI files inside EFI System Partition
EFIDIR ?= "/EFI/BOOT"

# Prefix where ESP is mounted inside rootfs. Set to empty if package is going
# to be installed to ESP directly
EFI_PREFIX ?= "/boot"

# Location inside rootfs.
EFI_FILES_PATH = "${EFI_PREFIX}${EFIDIR}"

# The EFI name for the architecture
EFI_ARCH ?= "INVALID"
EFI_ARCH:x86 = "ia32"
EFI_ARCH:x86-64 = "x64"
EFI_ARCH:aarch64 = "aa64"
EFI_ARCH:arm = "arm"
EFI_ARCH:riscv32 = "riscv32"
EFI_ARCH:riscv64 = "riscv64"

# Determine name of bootloader image
EFI_BOOT_IMAGE ?= "boot${EFI_ARCH}.efi"

GRUBPLATFORM = "efi"

DEPENDS:append = " grub-native sbsigntool-native"
RDEPENDS:${PN} = "bash grub-common virtual-grub-bootconf"

SRC_URI += "file://cfg \
            file://sbat.csv \
            file://0001-Commands-to-increment-and-decrement-variables.patch \
            file://0002-Implement-search_part_label.patch \
           "

# Determine the target arch for the grub modules
python __anonymous () {
    import re
    target = d.getVar('TARGET_ARCH')
    prefix = "" if d.getVar('EFI_PROVIDER') == "grub-efi" else "grub-efi-"
    if target == "x86_64":
        grubtarget = 'x86_64'
    elif re.match('i.86', target):
        grubtarget = 'i386'
    elif re.match('aarch64', target):
        grubtarget = 'arm64'
    elif re.match('arm', target):
        grubtarget = 'arm'
    elif re.match('riscv64', target):
        grubtarget = 'riscv64'
    elif re.match('riscv32', target):
        grubtarget = 'riscv32'
    else:
        raise bb.parse.SkipRecipe("grub-efi is incompatible with target %s" % target)
    grubimage = prefix + d.getVar("EFI_BOOT_IMAGE")
    d.setVar("GRUB_TARGET", grubtarget)
    d.setVar("GRUB_IMAGE", grubimage)
    prefix = "grub-efi-" if prefix == "" else ""
    d.setVar("GRUB_IMAGE_PREFIX", prefix)
}

inherit deploy

CACHED_CONFIGUREVARS += "ac_cv_path_HELP2MAN="
EXTRA_OECONF += "--enable-efiemu=no"

do_mkimage() {
    cd ${B}

    # list of modules got from here https://git.launchpad.net/~ubuntu-core-dev/grub/+git/ubuntu/tree/debian/build-efi-images?h=debian/2.06-2ubuntu12
    BASIC_MODULES="all_video boot btrfs cat chain configfile echo efifwsetup efinet ext2 fat font gettext gfxmenu
gfxterm gfxterm_background gzio halt help hfsplus iso9660 jpeg keystatus loadenv loopback linux ls lsefi lsefimmap
lsefisystab lssal memdisk minicmd normal ntfs part_apple part_msdos part_gpt password_pbkdf2 png probe reboot regexp
search search_fs_uuid search_fs_file search_label sleep smbios squash4 test true video xfs zfs zfscrypt zfsinfo"

    PLATFORM_SPECIFIC_MODULES="cpuid play tpm"

    GRUB_MODULES="${BASIC_MODULES} ${PLATFORM_SPECIFIC_MODULES} increment gpt"

    grub-mkimage -v -c ../cfg -p ${EFIDIR} -d ./grub-core/ \
                 --sbat ${WORKDIR}/sbat.csv \
                 -O ${GRUB_TARGET}-efi -o ./${GRUB_IMAGE_PREFIX}${GRUB_IMAGE} \
                 ${GRUB_MODULES}

    grub-editenv ${WORKDIR}/grubenv create
}

addtask mkimage before do_install after do_compile

do_install() {
    oe_runmake 'DESTDIR=${D}' -C grub-core install

    # Remove build host references...
    find "${D}" -name modinfo.sh -type f -exec \
        sed -i \
        -e 's,--sysroot=${STAGING_DIR_TARGET},,g' \
        -e 's|${DEBUG_PREFIX_MAP}||g' \
        -e 's:${RECIPE_SYSROOT_NATIVE}::g' \
        {} +

    install -d ${D}${EFI_FILES_PATH}
    install -m 644 ${WORKDIR}/git/${GRUB_IMAGE_PREFIX}${GRUB_IMAGE} ${D}${EFI_FILES_PATH}/${GRUB_IMAGE}

    install -d ${D}/boot/EFI/BOOT
    install -m 0644 ${WORKDIR}/grubenv ${D}/boot/EFI/BOOT/grubenv
}

SIGNING_DIR ?= "${WORKDIR}/git"
SIGNING_BINARIES ?= "*.efi"
SIGN_AFTER ?= "do_compile"
SIGN_BEFORE ?= "do_install"

# uefi-sign.bbclass defined in meta-intel layer
inherit uefi-sign

do_deploy() {
    install -m 644 ${WORKDIR}/git/${GRUB_IMAGE_PREFIX}${GRUB_IMAGE} ${DEPLOYDIR}
}

addtask deploy after do_install before do_build

FILES:${PN} = "${libdir}/grub/${GRUB_TARGET}-efi \
               ${datadir}/grub \
               ${EFI_FILES_PATH}/${GRUB_IMAGE} \
               ${EFI_FILES_PATH}/grubenv \
               "

# 64-bit binaries are expected for the bootloader with an x32 userland
INSANE_SKIP:${PN}:append:linux-gnux32 = " arch"
INSANE_SKIP:${PN}-dbg:append:linux-gnux32 = " arch"
INSANE_SKIP:${PN}:append:linux-muslx32 = " arch"
INSANE_SKIP:${PN}-dbg:append:linux-muslx32 = " arch"
