# Run the enapter-cloud-init bats suite in the official bats container, so no
# host install of bats/jq/awk is needed. The script under test lives one level
# up (the tests source ../enapter-cloud-init.sh), so the parent dir is mounted.
#
# SPDX-FileCopyrightText: 2026 Enapter <developers@enapter.com>
# SPDX-License-Identifier: Apache-2.0

BATS_IMAGE ?= bats/bats:latest
# Directory holding the script under test (mounted as /code in the container).
CODE_DIR := $(abspath $(CURDIR)/..)

.PHONY: test
test:
	docker run --rm -v "$(CODE_DIR):/code:ro" -w /code \
		--entrypoint sh "$(BATS_IMAGE)" \
		-c 'apk add --no-cache --quiet jq && bats tests/'
