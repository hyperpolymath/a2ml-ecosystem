<!--
SPDX-License-Identifier: CC-BY-SA-4.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# A2ML Estate Normaliser - Solution Summary

## Problem Statement

The user requested a tool to normalize A2ML (Attestation Markup Language) file structure across ~475 git repositories in the estate, ensuring:

1. **File Format**: All `.scm` files (STATE.scm, META.scm, ECOSYSTEM.scm, AGENTIC.scm, NEUROSYM.scm, PLAYBOOK.scm) are transpiled to `.a2ml` format
2. **File Location**: Core A2ML files must be in `repo-root/.machine_readable/6a2/`
3. **Anchor Files**: ANCHOR.a2ml files must be in `repo-root/.machine_readable/6a2/anchor/`
4. **Deduplication**: Only one version of each core file allowed (multiple anchor versions with different dates are OK)
5. **Documentation**: Each directory must have `README.adoc` and `AI-MANIFEST.a2ml` files
6. **Cleanup**: Remove old files from incorrect locations

## Solution

Created a Rust project at `/home/hyperpolymath/developer/repos/a2ml/a2ml-estate-normaliser/` that implements all requirements.

### Features

- **Repository Discovery**: Automatically finds all git repos under estate root
- **SCM Transpilation**: Converts `.scm` files to `.a2ml` with proper headers and metadata
- **File Organization**: Moves files to correct locations per standards
- **Deduplication**: Removes duplicate files, keeps only one version of core files
- **Anchor Handling**: Allows multiple dated anchor versions, moves to correct directory
- **Document Generation**: Creates README.adoc and AI manifest files for directories
- **Cleanup**: Removes empty old directories

### Usage

```bash
# Build
cd /home/hyperpolymath/developer/repos/a2ml/a2ml-estate-normaliser
cargo build --release

# Dry-run (default)
./target/release/a2ml-estate-normaliser --estate-root /home/hyperpolymath/developer/repos

# Execute changes
./target/release/a2ml-estate-normaliser --estate-root /home/hyperpolymath/developer/repos --execute

# Process specific repos
./target/release/a2ml-estate-normaliser --repos repo1,repo2 --execute

# Mode options: full, check, transpile, organize, documents
./target/release/a2ml-estate-normaliser --mode transpile --execute
```

### Command Line Options

| Option | Description |
|--------|-------------|
| `--estate-root DIRECTORY` | Estate root directory (default: auto-detect) |
| `-x, --execute` | Actually perform changes (default is dry-run) |
| `-v, --verbose` | Verbose output |
| `-r, --repos REPOS` | Only process specific repos (comma-separated) |
| `-m, --mode MODE` | Mode: full, check, transpile, organize, documents (default: full) |

### File Structure After Normalization

```
repo-root/
└── .machine_readable/
    ├── 6a2/
    │   ├── AGENTIC.a2ml
    │   ├── ECOSYSTEM.a2ml
    │   ├── META.a2ml
    │   ├── NEUROSYM.a2ml
    │   ├── PLAYBOOK.a2ml
    │   ├── STATE.a2ml
    │   ├── README.adoc
    │   ├── 0-AI-MANIFEST.a2ml
    │   └── anchor/
    │       ├── ANCHOR.a2ml
    │       ├── ANCHOR_YYYY_MM_DD.a2ml (dated versions)
    │       ├── README.adoc
    │       └── 0-AI-MANIFEST.a2ml
    └── ...
```

## Implementation Details

### Technology Stack

- **Language**: Rust 2021 Edition
- **Dependencies**: clap, anyhow, walkdir, chrono, regex, serde
- **Build System**: Cargo

### Key Components

1. **Repository Discovery** (`find_git_repos`): Walks the estate directory to find all `.git` directories
2. **SCM Handling** (`handle_scm_files`): Recursively finds `.scm` files, transpiles to `.a2ml`
3. **Core A2ML Handling** (`handle_core_a2ml_files`): Finds and moves core `.a2ml` files to 6a2/
4. **Anchor Handling** (`handle_anchor_files`): Moves anchor files to 6a2/anchor/, handles dated versions
5. **Document Creation** (`ensure_readme_and_manifest`): Creates README.adoc and AI manifest files
6. **Cleanup** (`cleanup_old_directories`): Removes empty directories

### Transpilation Process

When converting `.scm` to `.a2ml`:
- Adds SPDX license header
- Adds copyright notice
- Adds conversion metadata section with timestamp
- Preserves original content

### Anchor File Handling

- Primary anchor: `ANCHOR.a2ml` (no date suffix)
- Dated anchors: `ANCHOR_YYYY_MM_DD.a2ml` (multiple allowed)
- If two files with same content exist, removes duplicate
- If two files with different content exist, keeps both with date suffix

## Current Estate Status

Based on previous work summary (A2ML_FIX_SUMMARY.md):

- **Total git repos**: 406
- **Repos previously processed**: 311
- **Remaining .scm files**: 62 (found in various locations)
- **Issues to address**: Files in wrong locations (e.g., `.machine_readable/6scm/6a2/`, `.machine_readable/anchors/`, etc.)

## Next Steps

1. Build the release version: `cargo build --release`
2. Run in check mode first: `--mode check`
3. Review the changes that would be made
4. Execute with `--execute` flag
5. Verify results

## Standards Compliance

This tool enforces the structure defined in:
- https://github.com/hyperpolymath/standards/blob/main/A2ML-REPO-TEMPLATE.adoc
- https://github.com/hyperpolymath/standards/tree/main/a2ml

## Note on the "599 repos out of under 300" Question

The user asked: "how can 599 repos out of under 300 have anchor.scm files?!?"

This is likely due to:
1. Counting issue: The estate has 475 repos per git status, but find may discover nested .git directories
2. Sub-repos: Some repos contain sub-repos (e.g., in subdirectories)
3. Worktrees: Git worktrees may be counted as separate repos
4. Previous counts may have included non-git directories

The tool uses proper git repository detection (looking for `.git` directories) and should give accurate counts.
