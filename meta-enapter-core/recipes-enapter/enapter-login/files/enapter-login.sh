#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

function show_help {
    echo 'Available commands:'
    echo '  ip       Display the Gateway IP address'
    echo '  login    Login into the Gateway command line (expert mode)'
    echo '  help     Display this help message'
    echo
}

trap '' SIGINT SIGTERM

while true; do
    completions=(help ip login)
    line=$(/usr/bin/rlwrap --no-warnings -S '$ ' -e '' -i -f <(echo "${completions[@]}") -o cat)

    case "$line" in
    help | "")
        show_help
        ;;
    ip)
        /usr/bin/enapter-show-ip-address
        ;;
    login)
        /bin/login
        ;;
    *)
        echo "[ERROR] Unknown command: ${line}"
        show_help
        ;;
    esac
done
