#!/bin/bash
# SPDX-FileCopyrightText: 2023 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

. /usr/share/scripts/enapter-functions

perform_shutdown() {
  yes="$1"

  if [[ $yes -ne 1 ]]; then
    while true; do
      read -r -p "Are you sure you want to perform a shutdown? (y/n) " yn

      case $yn in
        [yY] ) info "Ok.";
          break;;
        [nN] ) info "Exiting...";
          exit;;
        * ) error "Invalid response, please use (y/n).";;
      esac
    done
  fi

  ensure_sync

  (sleep 1; systemctl --force --force poweroff) &
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

perform_shutdown "$yes"
