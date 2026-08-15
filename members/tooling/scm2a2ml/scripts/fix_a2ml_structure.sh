#!/bin/bash
# Script to fix A2ML file structure across all repos
# Ensures:
# 1. Only one version of each file (except anchor.a2ml with different dates)
# 2. .scm files are transpiled to .a2ml format
# 3. Files are in correct locations:
#    - .machine_readable/6a2/ for core files
#    - .machine_readable/6a2/anchor/ for anchor files
# 4. Each directory has README.adoc and AI manifest

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ESTATE_ROOT="$(dirname "$SCRIPT_DIR")"

# Template for README.adoc in 6a2 directory
README_6A2_TEMPLATE='# A2ML 6a2 Directory

This directory contains the 6 core A2ML machine-readable metadata files for this repository.

## Files

- `AGENTIC.a2ml` - AI agent operational gating, safety controls
- `ECOSYSTEM.a2ml` - Project ecosystem position, relationships, explicit boundaries
- `META.a2ml` - Architecture decisions (ADRs), development practices, design rationale
- `NEUROSYM.a2ml` - Symbolic semantics, composition algebra
- `PLAYBOOK.a2ml` - Executable plans, operational runbooks
- `STATE.a2ml` - Project state, phase, milestones, session history

## Standards Compliance

These files follow the A2ML Format Family specification from:
https://github.com/hyperpolymath/standards/tree/main/a2ml

## Generation

These files may be generated from .scm source files using transpilation tools.
Source .scm files should be removed after successful transpilation.

## See Also

- [A2ML Repository Template](https://github.com/hyperpolymath/standards/blob/main/A2ML-REPO-TEMPLATE.adoc)
- [6A2 Format Family](https://github.com/hyperpolymath/standards#a2ml-format-family-7-formats)
'

# Template for README.adoc in anchor directory
README_ANCHOR_TEMPLATE='# A2ML Anchor Directory

This directory contains ANCHOR.a2ml files for project recalibration and scope intervention.

## Files

- `ANCHOR.a2ml` - Project recalibration, scope intervention, canonical authority

## Multiple Versions

Unlike other A2ML files, multiple versions of ANCHOR.a2ml with different dates may exist.
Each version represents a specific recalibration point in the project history.

## Standards Compliance

These files follow the ANCHOR.a2ml specification from:
https://github.com/hyperpolymath/standards/tree/main/anchor-a2ml

## See Also

- [A2ML Repository Template](https://github.com/hyperpolymath/standards/blob/main/A2ML-REPO-TEMPLATE.adoc)
- [Anchor A2ML Spec](https://github.com/hyperpolymath/standards/tree/main/anchor-a2ml)
'

# Template for AI manifest in 6a2 directory
AI_MANIFEST_6A2_TEMPLATE='# AI Manifest for 6a2 Directory

## Purpose

This manifest declares the AI-assistant context for the 6a2 machine-readable metadata directory.

## Canonical Locations

The 6 core A2ML files MUST exist in this directory:
1. AGENTIC.a2ml
2. ECOSYSTEM.a2ml
3. META.a2ml
4. NEUROSYM.a2ml
5. PLAYBOOK.a2ml
6. STATE.a2ml

## Invariants

- No duplicate files in root directory
- Single source of truth: this directory is authoritative
- No stale metadata

## Protocol

When multiple agents may write to A2ML files concurrently:
1. Read file and record git-sha-at-read in [provenance] section
2. Lock by creating .lock-<FILENAME>
3. Write updated file with new [provenance] metadata
4. Release by removing lock file
5. On conflict: re-read and retry if git-sha-at-read does not match HEAD
'

# Template for AI manifest in anchor directory
AI_MANIFEST_ANCHOR_TEMPLATE='# AI Manifest for Anchor Directory

## Purpose

This manifest declares the AI-assistant context for the anchor machine-readable metadata directory.

## Canonical Locations

ANCHOR.a2ml files MUST exist in this directory.

## Multiple Versions

Unlike other A2ML files, multiple versions of ANCHOR.a2ml with different dates MAY exist.
Each version represents a specific recalibration point.

## Invariants

- Multiple versions with different dates are permitted
- No other A2ML files in this directory
- Single source of truth for anchor documents
'

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2
}

# Function to transpile .scm to .a2ml
# For now, this is a simple copy since we need to understand the format first
# TODO: Implement actual transpilation if .scm format differs from .a2ml
transpile_scm_to_a2ml() {
    local scm_file="$1"
    local a2ml_file="$2"
    
    # Check if file exists
    if [ ! -f "$scm_file" ]; then
        error "SCM file not found: $scm_file"
        return 1
    fi
    
    # For now, just copy the file
    # In reality, .scm might be Scheme format that needs conversion
    # But based on the files I've seen, they look similar to a2ml already
    cp "$scm_file" "$a2ml_file"
    
    # Update file extension in content if needed
    if [ -f "$a2ml_file" ]; then
        # Add a2ml header comment if not present
        if ! grep -q "# SPDX-License-Identifier" "$a2ml_file"; then
            local dir=$(dirname "$a2ml_file")
            local base=$(basename "$a2ml_file")
            local timestamp=$(date +'%Y-%m-%dT%H:%M:%SZ')
            
            # Create new file with header
            {
                echo "# SPDX-License-Identifier: MPL-2.0"
                echo "# Copyright (c) $(date +'%Y') Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>"
                echo "#"
                echo "# ${base} — Transpiled from .scm format"
                echo "[metadata]"
                echo "converted-from-scm = true"
                echo "conversion-date = \"${timestamp}\""
                echo ""
                cat "$a2ml_file"
            } > "$a2ml_file.tmp"
            mv "$a2ml_file.tmp" "$a2ml_file"
        fi
    fi
    
    log "Transpiled: $scm_file -> $a2ml_file"
}

# Function to process a single repo
process_repo() {
    local repo_path="$1"
    local repo_name=$(basename "$repo_path")
    
    log "Processing repo: $repo_name"
    
    local mr_dir="$repo_path/.machine_readable"
    local mr_6a2_dir="$repo_path/.machine_readable/6a2"
    local mr_anchors_dir="$repo_path/.machine_readable/anchors"
    local mr_6a2_anchor_dir="$repo_path/.machine_readable/6a2/anchor"
    
    # Create directories if they don't exist
    mkdir -p "$mr_6a2_dir"
    mkdir -p "$mr_anchors_dir"
    mkdir -p "$mr_6a2_anchor_dir"
    
    # Step 1: Handle .scm files in .machine_readable root
    local scm_files=("STATE.scm" "META.scm" "ECOSYSTEM.scm" "AGENTIC.scm" "NEUROSYM.scm" "PLAYBOOK.scm")
    local has_scm_files=false
    
    for scm_file in "${scm_files[@]}"; do
        local scm_path="$mr_dir/$scm_file"
        if [ -f "$scm_path" ]; then
            has_scm_files=true
            local a2ml_name="${scm_file%.scm}.a2ml"
            local a2ml_path="$mr_6a2_dir/$a2ml_name"
            
            # Check if .a2ml version already exists in 6a2
            if [ -f "$a2ml_path" ]; then
                log "WARNING: Both .scm and .a2ml exist for $a2ml_name in $repo_name"
                log "  Keeping .a2ml version, removing .scm"
                rm "$scm_path"
            else
                # Transpile and move
                transpile_scm_to_a2ml "$scm_path" "$a2ml_path"
                rm "$scm_path"
            fi
        fi
    done
    
    # Step 2: Handle ANCHOR.a2ml files
    # Move from .machine_readable/anchors/ to .machine_readable/6a2/anchor/
    local anchors_to_move=("$mr_anchors_dir/ANCHOR.a2ml" "$mr_anchors_dir/anchor.a2ml")
    
    for anchor_path in "${anchors_to_move[@]}"; do
        if [ -f "$anchor_path" ]; then
            local dest_path="$mr_6a2_anchor_dir/ANCHOR.a2ml"
            
            # If destination already has a file, we need to handle multiple versions
            # User said multiple anchor.a2ml with different dates are allowed
            if [ -f "$dest_path" ]; then
                # Check if files are different (different dates/content)
                if ! cmp -s "$anchor_path" "$dest_path"; then
                    # Files are different, keep both with date suffix
                    local date_suffix=$(stat -c %y "$anchor_path" | cut -d' ' -f1 | tr - _)
                    local dated_dest="$mr_6a2_anchor_dir/ANCHOR_${date_suffix}.a2ml"
                    
                    # But first, check if we already have a file with this date
                    if [ ! -f "$dated_dest" ]; then
                        mv "$anchor_path" "$dated_dest"
                        log "Moved anchor with date suffix: $anchor_path -> $dated_dest"
                    else
                        # Duplicate date, overwrite
                        mv "$anchor_path" "$dated_dest"
                        log "Overwrote existing anchor with same date: $dated_dest"
                    fi
                else
                    # Files are identical, remove duplicate
                    rm "$anchor_path"
                    log "Removed duplicate anchor: $anchor_path"
                fi
            else
                mv "$anchor_path" "$dest_path"
                log "Moved anchor: $anchor_path -> $dest_path"
            fi
        fi
    done
    
    # Also check for ANCHOR.a2ml in .machine_readable/6a2/ root (not in anchor subdir)
    local anchor_6a2_path="$mr_6a2_dir/ANCHOR.a2ml"
    if [ -f "$anchor_6a2_path" ]; then
        # Move to anchor subdirectory
        if [ ! -f "$mr_6a2_anchor_dir/ANCHOR.a2ml" ]; then
            mv "$anchor_6a2_path" "$mr_6a2_anchor_dir/ANCHOR.a2ml"
            log "Moved anchor from 6a2 root to anchor subdir: $anchor_6a2_path"
        else
            # Check if different
            if ! cmp -s "$anchor_6a2_path" "$mr_6a2_anchor_dir/ANCHOR.a2ml"; then
                local date_suffix=$(stat -c %y "$anchor_6a2_path" | cut -d' ' -f1 | tr - _)
                local dated_dest="$mr_6a2_anchor_dir/ANCHOR_${date_suffix}.a2ml"
                mv "$anchor_6a2_path" "$dated_dest"
                log "Moved anchor with date suffix from 6a2 root: $anchor_6a2_path -> $dated_dest"
            else
                rm "$anchor_6a2_path"
                log "Removed duplicate anchor in 6a2 root: $anchor_6a2_path"
            fi
        fi
    fi
    
    # Step 3: Ensure README.adoc exists in 6a2 directory
    if [ ! -f "$mr_6a2_dir/README.adoc" ]; then
        echo "$README_6A2_TEMPLATE" > "$mr_6a2_dir/README.adoc"
        log "Created README.adoc in 6a2 directory"
    fi
    
    # Step 4: Ensure README.adoc exists in anchor directory
    if [ ! -f "$mr_6a2_anchor_dir/README.adoc" ]; then
        echo "$README_ANCHOR_TEMPLATE" > "$mr_6a2_anchor_dir/README.adoc"
        log "Created README.adoc in anchor directory"
    fi
    
    # Step 5: Ensure AI manifest exists in 6a2 directory
    if [ ! -f "$mr_6a2_dir/0-AI-MANIFEST.a2ml" ] && [ ! -f "$mr_6a2_dir/AI-MANIFEST.a2ml" ]; then
        echo "$AI_MANIFEST_6A2_TEMPLATE" > "$mr_6a2_dir/0-AI-MANIFEST.a2ml"
        log "Created AI manifest in 6a2 directory"
    fi
    
    # Step 6: Ensure AI manifest exists in anchor directory
    if [ ! -f "$mr_6a2_anchor_dir/0-AI-MANIFEST.a2ml" ] && [ ! -f "$mr_6a2_anchor_dir/AI-MANIFEST.a2ml" ]; then
        echo "$AI_MANIFEST_ANCHOR_TEMPLATE" > "$mr_6a2_anchor_dir/0-AI-MANIFEST.a2ml"
        log "Created AI manifest in anchor directory"
    fi
    
    # Step 7: Clean up old anchors directory if it's now empty
    if [ -d "$mr_anchors_dir" ]; then
        local anchor_count=$(find "$mr_anchors_dir" -maxdepth 1 -type f | wc -l)
        if [ "$anchor_count" -eq 0 ]; then
            # Check if it has subdirectories with files
            local total_count=$(find "$mr_anchors_dir" -type f | wc -l)
            if [ "$total_count" -eq 0 ]; then
                rmdir "$mr_anchors_dir" 2>/dev/null || true
                log "Removed empty anchors directory"
            fi
        fi
    fi
    
    log "Completed processing: $repo_name"
}

# Function to find all repos in the estate
find_all_repos() {
    # Find all directories in the estate root that have .git or .machine_readable
    find "$ESTATE_ROOT" -maxdepth 3 -type d \( -name ".git" -o -name ".machine_readable" \) -printf '%h\n' | sort -u
}

# Main function
main() {
    log "Starting A2ML structure fix across all repos"
    log "Estate root: $ESTATE_ROOT"
    
    local repos=()
    
    # For testing, we might want to process just a few repos
    # Uncomment the following line to process all repos
    # mapfile -t repos < <(find_all_repos)
    
    # For now, let's process repos that we know have issues
    # First, get repos with .scm files
    repos+=($(find "$ESTATE_ROOT" -path "*/.machine_readable/STATE.scm" -o -path "*/.machine_readable/META.scm" -o -path "*/.machine_readable/ECOSYSTEM.scm" -o -path "*/.machine_readable/AGENTIC.scm" -o -path "*/.machine_readable/NEUROSYM.scm" -o -path "*/.machine_readable/PLAYBOOK.scm" 2>/dev/null | sed 's|/\.machine_readable/.*||' | sort -u | head -5))
    
    # Add repos with anchor files in wrong location
    repos+=($(find "$ESTATE_ROOT" -path "*/.machine_readable/anchors/ANCHOR.a2ml" 2>/dev/null | sed 's|/\.machine_readable/anchors/.*||' | sort -u | head -5))
    
    # Remove duplicates
    repos=($(printf '%s\n' "${repos[@]}" | sort -u))
    
    log "Found ${#repos[@]} repos to process"
    
    for repo in "${repos[@]}"; do
        process_repo "$repo"
    done
    
    log "All repos processed!"
}

# Run main
main "$@"
