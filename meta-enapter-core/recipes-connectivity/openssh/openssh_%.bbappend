do_install:append () {
    echo "HostKey /user/etc/ssh/ssh_host_rsa_key" >> ${D}${sysconfdir}/ssh/sshd_config
    echo "HostKey /user/etc/ssh/ssh_host_ecdsa_key" >> ${D}${sysconfdir}/ssh/sshd_config
    echo "HostKey /user/etc/ssh/ssh_host_ed25519_key" >> ${D}${sysconfdir}/ssh/sshd_config
}
