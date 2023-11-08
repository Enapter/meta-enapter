SYSTEMD_AUTO_ENABLE:${PN} = "disable"

# dnsmasq dbus support required by NetworkManager dns plugin
PACKAGECONFIG = "dbus"
