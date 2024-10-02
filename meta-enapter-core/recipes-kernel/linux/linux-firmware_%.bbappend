PACKAGES =+ "${PN}-mt7921u-license ${PN}-mt7921u"

# For mediatek MT7921U
LICENSE:${PN}-mt7921u = "Firmware-mediatek"
LICENSE:${PN}-mt7921u-license = "Firmware-mediatek"

FILES:${PN}-mt7921u-license = "${nonarch_base_libdir}/firmware/LICENCE.mediatek"
FILES:${PN}-mt7921u = " \
  ${nonarch_base_libdir}/firmware/mediatek/WIFI_RAM_CODE_MT7961_1.bin \
  ${nonarch_base_libdir}/firmware/mediatek/WIFI_MT7961_patch_mcu_1_2_hdr.bin \
"

RDEPENDS:${PN}-mt7921u = "${PN}-mt7921u-license"
