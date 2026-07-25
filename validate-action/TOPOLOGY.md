<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->
# TOPOLOGY.md — a2ml-validate-action

## Purpose

GitHub Action that validates `.a2ml` manifest files in a repository. Checks SPDX headers, required identity/version fields, attestation block structure, and section syntax. Used in CI pipelines across RSR repos to enforce A2ML compliance.

## Module Map

```
a2ml-validate-action/
├── action.yml            # GitHub Action metadata and entry point
├── src/
│   └── validate-a2ml.sh  # Validation script (delegates to shell logic)
├── examples/             # Example workflows using this action
├── docs/                 # Usage documentation
└── container/            # Containerfile for CI
```

## Data Flow

```
[GitHub workflow trigger] ──► [action.yml] ──► [validate-a2ml.sh]
                                                       │
                                            [scan repo for .a2ml files]
                                                       │
                                               [pass / fail with annotations]
```
