#!/bin/bash
# SPDX-FileCopyrightText: 2024 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

set -o errexit

. /usr/share/scripts/enapter-functions

install() {
    yes="$1"

    enapter-check-not-installed

    if [[ $yes -ne 1 ]]; then
      while true; do
        read -p "Are you sure you want to proceed with installing Enapter Linux on the HDD? (y/n) " yn

        case $yn in 
          [yY] ) info "Ok, we will proceed.";
            break;;
          [nN] ) info "Exiting...";
            exit;;
          * ) info "Invalid response. Please use (y/n).";
            exit 1;;
        esac
      done
    fi

    rauc install "$boot_mount/$install_bundle_name"

    ensure_sync

    info "Enapter Linux has been successfully installed on the HDD. Please remove the installation media (USB stick) and reboot the PC."
}

LONGOPTS=yes
OPTIONS=y

# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out "--options")
# -pass arguments only via   -- "$@"   to separate them correctly
# -if getopt fails, it complains itself to stdout
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@") || exit 2
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

yes=0

while true; do
    case "$1" in
        -y|--yes)
            yes=1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

install "$yes"
