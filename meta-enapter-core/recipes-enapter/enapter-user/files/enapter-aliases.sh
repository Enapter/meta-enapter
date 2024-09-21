#!/bin/bash

alias ll="ls -alh"
alias j="journalctl -o short-iso --no-hostname"
alias s="systemctl"
alias p="podman"
alias d="podman"
alias dc="docker-compose -f /user/etc/docker-compose/docker-compose.yml"

enapter-paths() {
    echo "/etc/enapter/         - enapter static configs"
    echo "/user/etc/enapter/    - enapter dynamic configs"
    echo "/lib/systemd/system/  - systemd services path"
    echo "/usr/bin/             - enapter binaries"
}

alias install-enapter-linux="sudo enapter-linux-install"
alias update-enapter-linux="sudo enapter-linux-update"
alias show-ip-address="enapter-show-ip-address"
alias factory-reset="sudo enapter-perform-factory-reset"
alias ping="sudo ping"
alias set-data-disk="sudo enapter-set-userspace-disk"
alias set-enapter-password="sudo enapter-set-password"

enapter-help() {
    echo "  Useful commands:"
    echo ""
    echo "  enapter-help             Display this help message"
    echo "  factory-reset            Clean all user data"
    echo "  install-enapter-linux    Perform on-disk installation"
    echo "  nmtui                    Network configuration"
    echo "  ping                     Execute ping command"
    echo "  set-data-disk            Set disk for storing user data"
    echo "  set-enapter-password     Set password for enapter user"
    echo ""
}
