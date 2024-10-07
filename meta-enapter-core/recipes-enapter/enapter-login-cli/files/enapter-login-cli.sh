#!/bin/sh
# SPDX-FileCopyrightText: 2024 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

if [ -f /usr/share/scripts/enapter-distro-variant ]; then
    . /usr/share/scripts/enapter-distro-variant
fi

show_help() {
    echo 'Available commands:'
    echo '  ip       Display the Gateway IP address'
    echo '  login    Login into the Gateway command line (expert mode)'
    echo '  help     Display this help message'
    echo '  reboot   Reboot the system'
    echo '  shutdown Shut down the system'
    echo
}

print_os_version() {
    echo ""
    name=$(grep '^NAME=' /etc/os-release | sed 's/^NAME=//; s/"//g')
    version=$(grep '^VERSION_ID=' /etc/os-release | sed 's/^VERSION_ID=//; s/"//g')
    echo "$name $version"
}

print_welcome_message() {
    default_welcome_message="
Welcome to Enapter Gateway!

Please access the Gateway web interface:
- Use \"http://enapter-gateway.local\" from a browser on your computer
  or mobile device connected to the same network as the Gateway.
- If the link above does not work, access the Gateway using IP address.
  To find out your IP address, type \"ip\" command into the command line below
  and press <Enter>.
  Then type the IP address into your browser address bar and press <Enter>.
"

    echo "${gateway_welcome_message:-$default_welcome_message}"
}

print_os_version
print_welcome_message
show_help

trap '' INT

while true; do
    line=$(/usr/bin/rlwrap --no-warnings -S '$ ' -o cat)

    case "$line" in
    help | "")
        show_help
        ;;
    ip)
        /usr/bin/enapter-show-ip-address
        ;;
    reboot)
        /usr/bin/enapter-reboot
        ;;
    shutdown)
        /usr/bin/enapter-shutdown
        ;;
    login)
        echo ""
        echo "To log in, use the following credentials:"
        echo "Login: enapter"
        echo "Password: [your superuser password] (default password is 'enapter')"
        echo ""
        /bin/login
        ;;
    *)
        echo "[ERROR] Unknown command: ${line}"
        show_help
        ;;
    esac
done
