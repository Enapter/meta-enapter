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

    info "Enapter Linux has been successfully installed on the HDD. Please remove the installation media (USB stick) and reboot the PC."
}

yes=0

while getopts "y" opt; do
  case "$opt" in
    y)
      yes=1
      ;;
    ?)
      exit 1
      ;;
  esac
done

install "$yes"
