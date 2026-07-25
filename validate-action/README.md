<!--
SPDX-License-Identifier: CC-BY-SA-4.0
SPDX-FileCopyrightText: 2025-2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->

# Overview

**GitHub Action to validate A2ML manifest files in your repository.**

A2ML (Agnostic Agent Markup Language) is a manifest format used across
RSR (Rhodium Standard Repository) projects to declare machine-readable
metadata, AI agent instructions, and project state. This action scans
for `.a2ml` files and validates their structure and required fields.

# Checks Performed

1.  **SPDX header** — Verifies `SPDX-License-Identifier` is present in
    the first 10 lines

2.  **Identity fields** — Requires `agent-id`, `name`, or `project`
    field (relaxed for AI-MANIFEST files)

3.  **Version field** — Checks for `version` or `schema_version`

4.  **Attestation blocks** — If an `[attestation]` section exists,
    validates it contains `proof`, `signature`, or `hash` fields

5.  **Section syntax** — Warns on malformed `[section]` headings with
    unclosed brackets

# Usage

Add to your workflow:

```yaml
name: Validate A2ML
on: [push, pull_request]

permissions:
  contents: read

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hyperpolymath/a2ml-validate-action@v1
        with:
          path: '.'        # Directory to scan (default: repo root)
          strict: 'false'  # Promote warnings to errors (default: false)
          # paths-ignore: defaults to vendored / fixture patterns; override
          # via newline-separated string. Use '' to disable.
```

## Inputs

| Input | Default | Description |
|----|----|----|
| `path` | `.` | Directory path to scan for `.a2ml` files |
| `strict` | `false` | When `true`, warnings become errors and the action fails on any issue |
| `paths-ignore` | *vendored & fixture defaults* | Newline-separated path fragments to skip. Substring match against each file path. Default set: `vendor/`, `vendored/`, `verified-container-spec/`, `.audittraining/`, `integration/fixtures/`, `test/fixtures/`, `tests/fixtures/`. Pass an empty string (`paths-ignore:` `’’`) to disable and scan everything. See <https://github.com/hyperpolymath/hypatia/pull/243> for the architectural rationale (content-pattern validators must distinguish targets from fixtures / vendored / training-corpus files that legitimately contain the very pattern being checked). |

### Why default-on path exemptions?

A2ML files inside vendored projects (e.g. `verified-container-spec/`)
have their own identity declarations elsewhere or are themselves
training corpora. Flagging every such file as "missing identity field"
is provenance noise, not signal. The defaults match the canonical RSR
vendored-content paths; override for project-specific carve-outs.

## Outputs

| Output          | Description                       |
|-----------------|-----------------------------------|
| `files-scanned` | Number of `.a2ml` files processed |
| `errors`        | Count of validation errors        |
| `warnings`      | Count of validation warnings      |

# Strict Mode

In strict mode (`strict:` `’true’`), all warnings are promoted to
errors. This is useful for repositories that require full A2ML
compliance, such as those following the RSR standard.

# Author

Jonathan D.A. Jewell \<[j.d.a.jewell@open.ac](j.d.a.jewell@open.ac).uk\>

# License

SPDX-License-Identifier: CC-BY-SA-4.0

See [LICENSE](LICENSE) for details.
