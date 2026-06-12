#!/bin/bash
# Minimal cloud-init for Amazon EC2.
#
# On EC2 instances (detected via DMI) it queries the Instance Metadata
# Service (IMDSv2 only) to:
#   - merge the launch keypair public keys into the persistent
#     authorized_keys file of the superuser;
#   - collect instance details into an env file for later consumption
#     by Enapter EMS WebUI (proof of instance ownership during setup).
#
# On non-EC2 systems it still writes the env file with
# CLOUD_PROVIDER="none" and CLOUD_INIT_STATUS="ready" so consumers can tell
# "bare-metal, cloud-init finished" apart from "script never ran".
#
# SPDX-FileCopyrightText: 2026 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

# The helper library is loaded from an overridable path so the script can be
# sourced (without side effects) by the bats test suite, which points
# $enapter_functions at a stub. In production this resolves to the installed
# library shipped by enapter-scripts.
: "${enapter_functions:=/usr/share/scripts/enapter-functions}"
# shellcheck source=/dev/null
. "$enapter_functions"

readonly imds_token_ttl=300
readonly curl_opts=(--silent --fail --connect-timeout 2 --max-time 10 --retry 5 --retry-connrefused)

# Atomically (mktemp + mv on the same filesystem) write the cloud-init env
# file. The first argument is CLOUD_PROVIDER, the second is CLOUD_INIT_STATUS;
# any further arguments are appended verbatim as KEY="value" lines.
write_cloud_init_env() {
  local provider="$1" status="$2"; shift 2
  local tmp_file line
  mkdir -p "$cloud_etc_dir"
  tmp_file=$(mktemp "$cloud_etc_dir/.cloud-init.env.XXXXXX")
  {
    printf 'CLOUD_PROVIDER="%s"\n' "$provider"
    printf 'CLOUD_INIT_STATUS="%s"\n' "$status"
    for line in "$@"; do printf '%s\n' "$line"; done
  } > "$tmp_file"
  chmod 644 "$tmp_file"
  mv -f "$tmp_file" "$cloud_init_env_file"
  info "Cloud-init env written (provider=$provider status=$status) to $cloud_init_env_file"
}

imds_get() {
  curl "${curl_opts[@]}" -H "X-aws-ec2-metadata-token: $imds_token" "$imds_base_url/$1"
}

# Returns the requested metadata value or an empty string if the path
# does not exist (e.g. public-ipv4 on instances without a public IP).
imds_get_optional() {
  imds_get "$1" || true
}

update_authorized_keys() {
  local keys_dir key_index key new_keys=""

  # Iterate over "<index>=<keypair name>" entries; tolerate instances
  # launched without a keypair (the listing is then empty or 404).
  local key_list
  key_list=$(imds_get_optional "meta-data/public-keys/")
  for key_index in $(echo "$key_list" | cut -d= -f1); do
    key=$(imds_get_optional "meta-data/public-keys/$key_index/openssh-key")
    [ -n "$key" ] && new_keys+="$key"$'\n'
  done

  [ -n "$new_keys" ] || { info "No SSH public keys available in instance metadata"; return 0; }

  # Target the path sshd actually reads (~enapter/.ssh/authorized_keys). On a
  # provisioned system enapter-authorized-ssh-keys-configurator (ordered before
  # us) has replaced it with a symlink onto the persistent /user partition, so
  # the write transparently persists. On a fresh/unprovisioned boot that
  # service is skipped (no /user, no rwfs marker), so we create a real file on
  # the volatile overlay — valid for this boot and refreshed from IMDS on every
  # subsequent boot. Writing the old /user path directly would be inert: sshd
  # never reads it and, without the symlink, nothing links it back.
  keys_dir=$(dirname "$enapter_authorized_keys")
  mkdir -p "$keys_dir"
  chown enapter:users "$keys_dir"
  chmod 700 "$keys_dir"
  touch "$enapter_authorized_keys"

  # Deduplicate by key type + blob (fields 1-2) so a differing comment
  # does not produce duplicates. Never remove existing keys.
  local added=0
  while IFS= read -r key; do
    [ -n "$key" ] || continue
    if ! awk -v t="$(echo "$key" | awk '{print $1" "$2}')" '($1" "$2) == t {found=1} END {exit !found}' \
        "$enapter_authorized_keys"; then
      echo "$key" >> "$enapter_authorized_keys"
      added=$((added + 1))
    fi
  done <<< "$new_keys"

  chown enapter:users "$enapter_authorized_keys"
  chmod 600 "$enapter_authorized_keys"
  info "Authorized SSH keys updated from EC2 instance metadata ($added added)"
}

main() {
  set -o errexit
  set -o pipefail

  # Off-cloud: publish a terminal env file and stop. The CLOUD_PROVIDER="none"
  # marker lets EMS WebUI tell bare-metal apart from a run that never finished.
  if ! running_on_ec2; then
    write_cloud_init_env none ready
    exit 0
  fi

  # Record the provider first, derived from DMI alone (no network). This marker
  # is therefore present even if IMDS is unreachable, letting Enapter EMS WebUI
  # tell "EC2 instance, metadata pending" apart from "not a cloud instance".
  # The full metadata is filled in below once IMDS answers; until then the
  # status stays "pending" and systemd keeps retrying the unit (Restart=).
  write_cloud_init_env aws pending

  imds_token=$(curl "${curl_opts[@]}" -X PUT \
    -H "X-aws-ec2-metadata-token-ttl-seconds: $imds_token_ttl" \
    "$imds_base_url/api/token") || fatal "Failed to obtain IMDSv2 token"

  # instance-id is the proof-of-ownership field consumed by EMS, so it is
  # mandatory: fail (and let the unit retry) until IMDS hands it over, rather
  # than publishing a "ready" env file with an empty INSTANCE_ID.
  local instance_id account_id
  instance_id=$(imds_get meta-data/instance-id) || fatal "Failed to read instance-id from IMDS"
  [ -n "$instance_id" ] || fatal "IMDS returned an empty instance-id"

  update_authorized_keys

  account_id=$(imds_get_optional "dynamic/instance-identity/document" | jq -r '.accountId // empty' || true)

  write_cloud_init_env aws ready \
    "INSTANCE_ID=\"$instance_id\"" \
    "INSTANCE_TYPE=\"$(imds_get_optional meta-data/instance-type)\"" \
    "AMI_ID=\"$(imds_get_optional meta-data/ami-id)\"" \
    "REGION=\"$(imds_get_optional meta-data/placement/region)\"" \
    "AVAILABILITY_ZONE=\"$(imds_get_optional meta-data/placement/availability-zone)\"" \
    "ACCOUNT_ID=\"$account_id\"" \
    "LOCAL_IPV4=\"$(imds_get_optional meta-data/local-ipv4)\"" \
    "PUBLIC_IPV4=\"$(imds_get_optional meta-data/public-ipv4)\""
}

# Run only when executed; sourcing (e.g. by the bats suite) just loads the
# functions above with no side effects.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
