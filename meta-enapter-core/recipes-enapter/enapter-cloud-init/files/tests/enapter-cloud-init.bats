#!/usr/bin/env bats
#
# Unit tests for enapter-cloud-init.sh. Run on a developer host / CI, never
# shipped to the image. See README.md for prerequisites (bats, jq).
#
# SPDX-FileCopyrightText: 2026 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

setup() {
  export enapter_functions="$BATS_TEST_DIRNAME/fixtures/enapter-functions-stub.sh"
  # Sourcing only loads functions; the BASH_SOURCE guard keeps main() from
  # running. The stub (via $enapter_functions) points all writes at
  # $BATS_TEST_TMPDIR.
  source "$BATS_TEST_DIRNAME/../enapter-cloud-init.sh"
}

# Portable "octal permission bits" helper (GNU stat vs BSD/macOS stat).
file_mode() { stat -c '%a' "$1" 2>/dev/null || stat -f '%Lp' "$1"; }

# A curl() shadowing the real binary, serving a full EC2 IMDS dataset keyed on
# the requested path (always the last argument).
_imds_full() {
  curl() {
    local url="${!#}" path
    path="${url#"$imds_base_url"/}"
    case "$path" in
      api/token)                              echo "TEST-TOKEN" ;;
      meta-data/instance-id)                  echo "i-0123456789abcdef0" ;;
      meta-data/instance-type)                echo "t3.micro" ;;
      meta-data/ami-id)                       echo "ami-aaaaaaaa" ;;
      meta-data/placement/region)             echo "eu-central-1" ;;
      meta-data/placement/availability-zone)  echo "eu-central-1a" ;;
      meta-data/local-ipv4)                   echo "10.0.0.5" ;;
      meta-data/public-ipv4)                  echo "1.2.3.4" ;;
      meta-data/public-keys/)                 printf '0=launchkey\n' ;;
      meta-data/public-keys/0/openssh-key)    echo "ssh-ed25519 AAAAKEYBLOB launch@host" ;;
      dynamic/instance-identity/document)     echo '{"accountId":"123456789012"}' ;;
      *)                                      return 22 ;;  # curl --fail: HTTP 4xx
    esac
  }
}

@test "off-cloud writes provider=none/status=ready and exits 0" {
  running_on_ec2() { return 1; }

  run main
  [ "$status" -eq 0 ]
  [ -f "$cloud_init_env_file" ]
  grep -qx 'CLOUD_PROVIDER="none"' "$cloud_init_env_file"
  grep -qx 'CLOUD_INIT_STATUS="ready"' "$cloud_init_env_file"
}

@test "write_cloud_init_env emits provider/status/extra lines, mode 644, atomically" {
  run write_cloud_init_env aws ready 'INSTANCE_ID="i-abc"'
  [ "$status" -eq 0 ]

  grep -qx 'CLOUD_PROVIDER="aws"'        "$cloud_init_env_file"
  grep -qx 'CLOUD_INIT_STATUS="ready"'   "$cloud_init_env_file"
  grep -qx 'INSTANCE_ID="i-abc"'         "$cloud_init_env_file"
  [ "$(file_mode "$cloud_init_env_file")" = "644" ]

  # The atomic rename must leave no .cloud-init.env.* temp behind.
  run bash -c "ls \"$cloud_etc_dir\"/.cloud-init.env.* 2>/dev/null"
  [ -z "$output" ]
}

@test "update_authorized_keys dedups by type+blob and appends new keys" {
  mkdir -p "$(dirname "$enapter_authorized_keys")"
  # Pre-existing key: same type+blob as a launch key but a different comment.
  printf 'ssh-ed25519 AAAAEXISTING existing@old\n' > "$enapter_authorized_keys"

  curl() {
    local url="${!#}" path
    path="${url#"$imds_base_url"/}"
    case "$path" in
      meta-data/public-keys/)              printf '0=dup\n1=fresh\n' ;;
      meta-data/public-keys/0/openssh-key) echo "ssh-ed25519 AAAAEXISTING launch@new" ;;
      meta-data/public-keys/1/openssh-key) echo "ssh-rsa AAAAFRESH brand@new" ;;
      *)                                   return 22 ;;
    esac
  }

  run update_authorized_keys
  [ "$status" -eq 0 ]

  # Duplicate blob (differing only by comment) is not added twice.
  [ "$(grep -c 'AAAAEXISTING' "$enapter_authorized_keys")" -eq 1 ]
  # New key appended.
  grep -q 'AAAAFRESH' "$enapter_authorized_keys"
  # Existing key never removed.
  grep -q 'existing@old' "$enapter_authorized_keys"
}

@test "update_authorized_keys tolerates an empty key listing" {
  curl() {
    local url="${!#}" path
    path="${url#"$imds_base_url"/}"
    case "$path" in
      meta-data/public-keys/) echo "" ;;
      *)                      return 22 ;;
    esac
  }

  run update_authorized_keys
  [ "$status" -eq 0 ]
  [[ "$output" == *"No SSH public keys"* ]]
}

@test "imds_get_optional returns empty string on curl failure" {
  curl() { return 22; }
  imds_token="x"

  run imds_get_optional "meta-data/does-not-exist"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "on EC2 writes ready env with instance metadata" {
  running_on_ec2() { return 0; }
  _imds_full

  run main
  [ "$status" -eq 0 ]

  grep -qx 'CLOUD_PROVIDER="aws"'                "$cloud_init_env_file"
  grep -qx 'CLOUD_INIT_STATUS="ready"'           "$cloud_init_env_file"
  grep -qx 'INSTANCE_ID="i-0123456789abcdef0"'   "$cloud_init_env_file"
  grep -qx 'INSTANCE_TYPE="t3.micro"'            "$cloud_init_env_file"
  grep -qx 'REGION="eu-central-1"'               "$cloud_init_env_file"
  grep -qx 'ACCOUNT_ID="123456789012"'           "$cloud_init_env_file"
}

@test "empty instance-id fails and leaves status pending" {
  running_on_ec2() { return 0; }
  curl() {
    local url="${!#}" path
    path="${url#"$imds_base_url"/}"
    case "$path" in
      api/token)             echo "TEST-TOKEN" ;;
      meta-data/instance-id) echo "" ;;   # IMDS not ready yet
      *)                     return 22 ;;
    esac
  }

  run main
  [ "$status" -eq 1 ]
  # The pending marker written before the IMDS query must survive.
  grep -qx 'CLOUD_PROVIDER="aws"'        "$cloud_init_env_file"
  grep -qx 'CLOUD_INIT_STATUS="pending"' "$cloud_init_env_file"
}
