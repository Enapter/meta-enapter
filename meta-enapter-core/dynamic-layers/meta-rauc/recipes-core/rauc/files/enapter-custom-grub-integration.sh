#!/bin/bash
# SPDX-FileCopyrightText: 2024 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

. /usr/share/scripts/enapter-variables

state_good="good"
state_bad="bad"
ok_value_good=1
ok_value_bad=0
no_retries=-1
default_retries=1
bootname_a="A"
bootname_b="B"

set -e

function get_state ()
{
	bootname=$1
	ok_value=$($grub_editenv "$grubenv_path" list | sed -n "s/^${bootname}_OK=//p")
	if [[ "$ok_value" -eq $ok_value_good ]]; then
		state=$state_good
	else
		state=$state_bad
	fi
	echo "$state"
}

function set_state ()
{
	bootname=$1
	state=$2
	if [[ "$state" == "$state_good" ]]; then
		ok_value="$ok_value_good"
		try_value="$no_retries"
	else
		ok_value="$ok_value_bad"
		try_value="$default_retries"
	fi

	$grub_editenv "$grubenv_path" set "${bootname}_OK=$ok_value"
	$grub_editenv "$grubenv_path" set "${bootname}_TRY=$try_value"
}

function get_primary ()
{
	order_value=$($grub_editenv "$grubenv_path" list | sed -n "s/^ORDER=//p")
	# Extract the first word from ORDER (e.g. "A B" -> "A").
	# POSIX sh has no array indexing, so use for...break to get the first element.
	for slot in $order_value; do
		bootname="$slot"
		break
	done

	if [[ -z "$bootname" ]]; then
		exit 1
	fi

	echo "$bootname"
}

# When setting the primary slot we must also set <slot>_TRY=1 so GRUB
# will actually attempt to boot it on the next boot (TRY=0 means skip).
function set_primary ()
{
	bootname=$1
	if [[ "$bootname" == "$bootname_a" ]]; then
		order_value="$bootname_a $bootname_b"
	elif [[ "$bootname" == "$bootname_b" ]]; then
		order_value="$bootname_b $bootname_a"
	else
		exit 1
	fi

	$grub_editenv "$grubenv_path" set "ORDER=$order_value"
	$grub_editenv "$grubenv_path" set "${bootname}_OK=$ok_value_good"
	$grub_editenv "$grubenv_path" set "${bootname}_TRY=$default_retries"
}

if [ "$1" = "get-state" ]; then
	shift
	get_state "$@"
elif [ "$1" = "set-state" ]; then
	shift
	set_state "$@"
elif [ "$1" = "get-primary" ]; then
	shift
	get_primary "$@"
elif [ "$1" = "set-primary" ]; then
	shift
	set_primary "$@"
fi
