PACKAGES =+ "${PN}-mt7921u-license ${PN}-mt7921u"

# Add upstream source
SRC_URI += "https://www.kernel.org/pub/linux/kernel/firmware/linux-firmware-20250627.tar.gz;name=upstream"
SRC_URI[upstream.sha256sum] = "17121ce9493818c81c1ede39e86a49e8d633a8d15104fc675f2b281f0f9060e1"

# For mediatek MT7921U
LICENSE:${PN}-mt7921u = "Firmware-mediatek"
LICENSE:${PN}-mt7921u-license = "Firmware-mediatek"

FILES:${PN}-mt7921u-license = "${nonarch_base_libdir}/firmware/LICENCE.mediatek"
FILES:${PN}-mt7921u = " \
  ${nonarch_base_libdir}/firmware/mediatek/WIFI_RAM_CODE_MT7961_1.bin \
  ${nonarch_base_libdir}/firmware/mediatek/WIFI_MT7961_patch_mcu_1_2_hdr.bin \
"

FILES:${PN}-iwlwifi-misc   = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-*.ucode* \
    ${nonarch_base_libdir}/firmware/iwlwifi-*.pnvm* \
"

do_install:append() {
    # Extract and install all .pnvm files from upstream
    cd ${WORKDIR}/linux-firmware-20250627
    for pnvm in iwlwifi-*.pnvm; do
        if [ -f "$pnvm" ]; then
            install -m 0644 "$pnvm" ${D}${nonarch_base_libdir}/firmware/
        fi
    done
}

RDEPENDS:${PN}-mt7921u = "${PN}-mt7921u-license"
