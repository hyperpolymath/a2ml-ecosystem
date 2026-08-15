#!/bin/bash
# Script to fix A2ML file structure across all repos
# Corrected version that only processes git repo roots

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ESTATE_ROOT="$(dirname "$SCRIPT_DIR")"

# Template for README.adoc in 6a2 directory
README_6A2='# A2ML 6a2 Directory

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
README_ANCHOR='# A2ML Anchor Directory

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
AI_MANIFEST_6A2='# AI Manifest for 6a2 Directory

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
AI_MANIFEST_ANCHOR='# AI Manifest for Anchor Directory

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

# Function to transpile .scm to .a2ml
transpile_scm_to_a2ml() {
    local scm_file="$1"
    local a2ml_file="$2"
    
    if [ ! -f "$scm_file" ]; then
        echo "ERROR: SCM file not found: $scm_file" >&2
        return 1
    fi
    
    # Copy the file
    cp "$scm_file" "$a2ml_file"
    
    # Add a2ml header comment if not present
    if ! grep -q "# SPDX-License-Identifier" "$a2ml_file" 2>/dev/null; then
        local base=$(basename "$a2ml_file")
        local timestamp=$(date +'%Y-%m-%dT%H:%M:%SZ')
        
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
    
    log "Transpiled: $scm_file -> $a2ml_file"
}

# Function to process a single git repo
process_repo() {
    local repo_path="$1"
    local repo_name=$(basename "$repo_path")
    
    log "Processing: $repo_name"
    
    local mr_dir="$repo_path/.machine_readable"
    local mr_6a2_dir="$repo_path/.machine_readable/6a2"
    local mr_anchors_dir="$repo_path/.machine_readable/anchors"
    local mr_6a2_anchor_dir="$repo_path/.machine_readable/6a2/anchor"
    
    # Create directories if they don't exist
    mkdir -p "$mr_6a2_dir"
    mkdir -p "$mr_6a2_anchor_dir"
    
    # Step 1: Handle .scm files in .machine_readable root
    local scm_files=("STATE.scm" "META.scm" "ECOSYSTEM.scm" "AGENTIC.scm" "NEUROSYM.scm" "PLAYBOOK.scm")
    local moved_scm=false
    
    for scm_file in "${scm_files[@]}"; do
        local scm_path="$mr_dir/$scm_file"
        if [ -f "$scm_path" ]; then
            moved_scm=true
            local a2ml_name="${scm_file%.scm}.a2ml"
            local a2ml_path="$mr_6a2_dir/$a2ml_name"
            
            # Check if .a2ml version already exists in 6a2
            if [ -f "$a2ml_path" ]; then
                log "  WARNING: Both .scm and .a2ml exist for $a2ml_name - removing .scm"
                rm "$scm_path"
            else
                transpile_scm_to_a2ml "$scm_path" "$a2ml_path"
                rm "$scm_path"
            fi
        fi
    done
    
    # Step 2: Handle ANCHOR.a2ml files
    local anchor_changed=false
    
    # Check if we have anchor in .machine_readable/anchors/
    if [ -f "$mr_anchors_dir/ANCHOR.a2ml" ]; then
        anchor_changed=true
        local dest_path="$mr_6a2_anchor_dir/ANCHOR.a2ml"
        
        if [ -f "$dest_path" ]; then
            # Check if files are different
            if ! cmp -s "$mr_anchors_dir/ANCHOR.a2ml" "$dest_path"; then
                # Files are different, keep both with date suffix
                local date_suffix=$(stat -c %y "$mr_anchors_dir/ANCHOR.a2ml" | cut -d' ' -f1 | tr - _)
                local dated_dest="$mr_6a2_anchor_dir/ANCHOR_${date_suffix}.a2ml"
                
                if [ ! -f "$dated_dest" ]; then
                    mv "$mr_anchors_dir/ANCHOR.a2ml" "$dated_dest"
                    log "  Moved anchor with date: ANCHOR.a2ml -> ANCHOR_${date_suffix}.a2ml"
                else
                    mv "$mr_anchors_dir/ANCHOR.a2ml" "$dated_dest"
                    log "  Overwrote anchor with same date: $dated_dest"
                fi
            else
                # Files are identical, remove duplicate
                rm "$mr_anchors_dir/ANCHOR.a2ml"
                log "  Removed duplicate anchor from anchors/"
            fi
        else
            mv "$mr_anchors_dir/ANCHOR.a2ml" "$dest_path"
            log "  Moved anchor: anchors/ -> 6a2/anchor/"
        fi
    fi
    
    # Check if we have anchor in .machine_readable/6a2/ (not in anchor subdir)
    if [ -f "$mr_6a2_dir/ANCHOR.a2ml" ]; then
        anchor_changed=true
        local dest_path="$mr_6a2_anchor_dir/ANCHOR.a2ml"
        
        if [ -f "$dest_path" ]; then
            # Check if files are different
            if ! cmp -s "$mr_6a2_dir/ANCHOR.a2ml" "$dest_path"; then
                local date_suffix=$(stat -c %y "$mr_6a2_dir/ANCHOR.a2ml" | cut -d' ' -f1 | tr - _)
                local dated_dest="$mr_6a2_anchor_dir/ANCHOR_${date_suffix}.a2ml"
                mv "$mr_6a2_dir/ANCHOR.a2ml" "$dated_dest"
                log "  Moved anchor with date from 6a2/: ANCHOR.a2ml -> ANCHOR_${date_suffix}.a2ml"
            else
                rm "$mr_6a2_dir/ANCHOR.a2ml"
                log "  Removed duplicate anchor from 6a2/"
            fi
        else
            mv "$mr_6a2_dir/ANCHOR.a2ml" "$dest_path"
            log "  Moved anchor: 6a2/ -> 6a2/anchor/"
        fi
    fi
    
    # Step 3: Ensure README.adoc exists in 6a2 directory
    if [ ! -f "$mr_6a2_dir/README.adoc" ]; then
        echo "$README_6A2" > "$mr_6a2_dir/README.adoc"
        log "  Created README.adoc in 6a2/"
    fi
    
    # Step 4: Ensure README.adoc exists in anchor directory
    if [ ! -f "$mr_6a2_anchor_dir/README.adoc" ]; then
        echo "$README_ANCHOR" > "$mr_6a2_anchor_dir/README.adoc"
        log "  Created README.adoc in 6a2/anchor/"
    fi
    
    # Step 5: Ensure AI manifest exists in 6a2 directory
    if [ ! -f "$mr_6a2_dir/0-AI-MANIFEST.a2ml" ] && [ ! -f "$mr_6a2_dir/AI-MANIFEST.a2ml" ]; then
        echo "$AI_MANIFEST_6A2" > "$mr_6a2_dir/0-AI-MANIFEST.a2ml"
        log "  Created AI manifest in 6a2/"
    fi
    
    # Step 6: Ensure AI manifest exists in anchor directory
    if [ ! -f "$mr_6a2_anchor_dir/0-AI-MANIFEST.a2ml" ] && [ ! -f "$mr_6a2_anchor_dir/AI-MANIFEST.a2ml" ]; then
        echo "$AI_MANIFEST_ANCHOR" > "$mr_6a2_anchor_dir/0-AI-MANIFEST.a2ml"
        log "  Created AI manifest in 6a2/anchor/"
    fi
    
    # Step 7: Clean up old anchors directory if it's now empty
    if [ -d "$mr_anchors_dir" ]; then
        if [ -z "$(ls -A "$mr_anchors_dir" 2>/dev/null)" ]; then
            rmdir "$mr_anchors_dir" 2>/dev/null || true
            log "  Removed empty anchors/ directory"
        fi
    fi
    
    log "  Done: $repo_name"
}

# Function to get all git repo roots
get_git_repos() {
    find "$ESTATE_ROOT" -name ".git" -type d -printf '%h\n' | sort -u
}

# Main function
main() {
    log "Starting A2ML structure fix"
    log "Estate root: $ESTATE_ROOT"
    
    local all_repos=()
    mapfile -t all_repos < <(get_git_repos)
    
    log "Found ${#all_repos[@]} git repos"
    
    # Find repos that need processing
    local repos_to_process=()
    
    # Repos with .scm files
    for repo in "${all_repos[@]}"; do
        local mr_dir="$repo/.machine_readable"
        if [ -d "$mr_dir" ]; then
            for f in STATE.scm META.scm ECOSYSTEM.scm AGENTIC.scm NEUROSYM.scm PLAYBOOK.scm; do
                if [ -f "$mr_dir/$f" ]; then
                    repos_to_process+=("$repo")
                    break
                fi
            done
        fi
    done
    
    # Repos with anchor files in wrong location
    for repo in "${all_repos[@]}"; do
        local mr_dir="$repo/.machine_readable"
        if [ -f "$mr_dir/anchors/ANCHOR.a2ml" ] || [ -f "$mr_dir/6a2/ANCHOR.a2ml" ]; then
            # Only add if not already in list
            if ! printf '%s\n' "${repos_to_process[@]}" | grep -q "^$repo$"; then
                repos_to_process+=("$repo")
            fi
        fi
    done
    
    log "Repos needing processing: ${#repos_to_process[@]}"
    
    # For safety, let's process in batches and show what will be done
    if [ ${#repos_to_process[@]} -eq 0 ]; then
        log "No repos need processing"
        return 0
    fi
    
    # Process each repo
    for repo in "${repos_to_process[@]}"; do
        process_repo "$repo"
    done
    
    log "All repos processed!"
}

main "$@"
