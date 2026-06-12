# shellcheck shell=bash
# Test stub for the enapter-functions helper library.
#
# enapter-cloud-init.sh sources whatever $enapter_functions points at; the
# bats suite points it here so the script can be loaded on a developer host
# without the installed /usr/share/scripts files (which themselves source
# absolute paths). It provides the handful of functions and variables the
# script actually consumes, redirecting all writes under $BATS_TEST_TMPDIR.
#
# SPDX-FileCopyrightText: 2026 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

info()  { echo "[INFO] $1"; }
error() { echo "[ERROR] $1" 1>&2; }
debug() { echo "[DEBUG] $1"; }
fatal() { echo "[FATAL] $1" 1>&2; exit 1; }

# DMI detection is environment-specific; individual tests redefine this to
# simulate cloud / non-cloud hosts.
running_on_ec2() { return 1; }

# chown needs root and an "enapter" user that does not exist on a dev host;
# neutralise it so update_authorized_keys can be exercised unprivileged.
chown() { return 0; }

# Variables normally provided by enapter-variables, pointed at a writable
# scratch area. ${var:-default} lets a test pre-seed a path before sourcing.
_test_root="${BATS_TEST_TMPDIR:-/tmp}"
cloud_etc_dir="${cloud_etc_dir:-$_test_root/etc/enapter/cloud}"
cloud_init_env_file="${cloud_init_env_file:-$cloud_etc_dir/cloud-init.env}"
imds_base_url="${imds_base_url:-http://169.254.169.254/latest}"
enapter_authorized_keys="${enapter_authorized_keys:-$_test_root/home/enapter/.ssh/authorized_keys}"
