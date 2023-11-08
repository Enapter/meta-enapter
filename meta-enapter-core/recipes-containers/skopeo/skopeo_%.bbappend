do_install:append() {
  install -d ${D}${base_libdir}
  ln -s -r ${D}${base_libdir} ${D}/lib64
}

FILES:${PN} += " \
    /lib \
    /lib64 \
"
