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
