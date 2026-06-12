# Helper shell functions
#
# SPDX-FileCopyrightText: 2024 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

RED='\033[0;31m'
NC='\033[0m' # No Color

. /usr/share/scripts/enapter-variables

info() {
  echo "[INFO] $1"
  echo
}

error() {
  echo 1>&2
  echo -e "${RED}[ERROR] $1${NC}" 1>&2
  echo 1>&2
}

fatal() {
  echo 1>&2
  echo -e "${RED}[FATAL] $1${NC}" 1>&2
  echo 1>&2
  exit 1
}

debug() {
  echo "[DEBUG] $1"
}

ensure_sync() {
  sync; sync; sync
}

running_on_ec2() {
  # DMI-based Amazon EC2 detection (covers Nitro and Xen instance generations)
  local vendor uuid
  vendor=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null)
  [ "$vendor" = "Amazon EC2" ] && return 0
  uuid=$(cat /sys/class/dmi/id/product_uuid 2>/dev/null)
  case "${uuid,,}" in ec2*) return 0 ;; esac
  uuid=$(cat /sys/hypervisor/uuid 2>/dev/null)
  case "${uuid,,}" in ec2*) return 0 ;; esac
  return 1
}
