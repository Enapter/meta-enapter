do_install:append () {
    # Runtime drop-ins (volatile overlay) may override the hardening below.
    # sshd uses the first obtained value for each keyword, so the Include
    # must come before everything else in sshd_config.
    sed -i '1i Include /etc/ssh/sshd_config.d/*.conf' ${D}${sysconfdir}/ssh/sshd_config
    install -d ${D}${sysconfdir}/ssh/sshd_config.d

    echo "HostKey /user/etc/ssh/ssh_host_rsa_key" >> ${D}${sysconfdir}/ssh/sshd_config
    echo "HostKey /user/etc/ssh/ssh_host_ecdsa_key" >> ${D}${sysconfdir}/ssh/sshd_config
    echo "HostKey /user/etc/ssh/ssh_host_ed25519_key" >> ${D}${sysconfdir}/ssh/sshd_config

    # Secure defaults for the read-only rootfs: no root login, no password
    # auth. enapter-password-configurator re-enables password auth at runtime
    # via a drop-in on non-cloud (non-EC2) installations only.
    echo "PermitRootLogin no" >> ${D}${sysconfdir}/ssh/sshd_config
    echo "PasswordAuthentication no" >> ${D}${sysconfdir}/ssh/sshd_config
    echo "KbdInteractiveAuthentication no" >> ${D}${sysconfdir}/ssh/sshd_config
}

FILES:${PN}-sshd += " \
    ${sysconfdir}/ssh/sshd_config.d \
"
