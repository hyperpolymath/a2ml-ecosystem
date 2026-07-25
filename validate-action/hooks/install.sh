#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Install the version-controlled git hooks for this repo.
# Points git at the committed hooks/ directory (reproducible across clones),
# rather than copying into the un-versioned .git/hooks/.

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

git config core.hooksPath hooks
chmod +x hooks/pre-commit

echo "Installed: core.hooksPath -> hooks/  (pre-commit active)"
