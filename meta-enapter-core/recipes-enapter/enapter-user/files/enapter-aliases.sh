#!/bin/bash

alias ll="ls -alh"
alias j="journalctl -o short-iso --no-hostname"
alias s="systemctl"
alias p="podman"
alias d="podman"
alias dc="docker-compose -f /user/etc/docker-compose/docker-compose.yml"

alias os-install="sudo enapter-linux-install"
alias os-update="sudo enapter-linux-update"
alias show-ip-address="enapter-show-ip-address"
alias factory-reset="sudo enapter-perform-factory-reset"
alias ping="sudo ping"
alias set-data-disk="sudo enapter-set-userspace-disk"
alias set-enapter-password="sudo enapter-set-password"
alias list-disks="sudo lsblk -o NAME,PATH,SIZE,MODEL,MOUNTPOINTS,PARTLABEL"

commands-help() {
    echo "  Useful commands:"
    echo ""
    echo "  commands-help            Display this help message"
    echo "  factory-reset            Clean all user data"
    echo "  os-install               Perform on-disk installation"
    echo "  list-disks               Show system disks information"
    echo "  nmtui                    Network configuration"
    echo "  ping                     Execute ping command"
    echo "  set-data-disk            Set disk for storing user data"
    echo "  set-enapter-password     Set password for enapter user"
    echo ""
}
