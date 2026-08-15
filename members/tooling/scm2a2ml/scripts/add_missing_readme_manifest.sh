#!/bin/bash
# Add missing README.adoc and AI manifest to all 6a2 directories

set -euo pipefail

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
'

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
'

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
'

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

echo "Adding missing README.adoc and AI manifest to all 6a2 directories..."

TMPFILE=$(mktemp)
find . -name ".git" -type d -printf '%h\n' | sort -u > "$TMPFILE"

TOTAL=0
ADDED_README_6A2=0
ADDED_AI_6A2=0
ADDED_README_ANCHOR=0
ADDED_AI_ANCHOR=0

while IFS= read -r repo; do
    mr_6a2="$repo/.machine_readable/6a2"
    mr_6a2_anchor="$repo/.machine_readable/6a2/anchor"
    
    if [ -d "$mr_6a2" ]; then
        TOTAL=$((TOTAL + 1))
        
        # Add README.adoc if missing
        if [ ! -f "$mr_6a2/README.adoc" ]; then
            echo "$README_6A2" > "$mr_6a2/README.adoc"
            ADDED_README_6A2=$((ADDED_README_6A2 + 1))
            echo "  Added README.adoc to $mr_6a2"
        fi
        
        # Add AI manifest if missing
        if [ ! -f "$mr_6a2/0-AI-MANIFEST.a2ml" ] && [ ! -f "$mr_6a2/AI-MANIFEST.a2ml" ]; then
            echo "$AI_MANIFEST_6A2" > "$mr_6a2/0-AI-MANIFEST.a2ml"
            ADDED_AI_6A2=$((ADDED_AI_6A2 + 1))
            echo "  Added AI manifest to $mr_6a2"
        fi
        
        # Add to anchor subdirectory if it exists
        if [ -d "$mr_6a2_anchor" ]; then
            # Add README.adoc if missing
            if [ ! -f "$mr_6a2_anchor/README.adoc" ]; then
                echo "$README_ANCHOR" > "$mr_6a2_anchor/README.adoc"
                ADDED_README_ANCHOR=$((ADDED_README_ANCHOR + 1))
                echo "  Added README.adoc to $mr_6a2_anchor"
            fi
            
            # Add AI manifest if missing
            if [ ! -f "$mr_6a2_anchor/0-AI-MANIFEST.a2ml" ] && [ ! -f "$mr_6a2_anchor/AI-MANIFEST.a2ml" ]; then
                echo "$AI_MANIFEST_ANCHOR" > "$mr_6a2_anchor/0-AI-MANIFEST.a2ml"
                ADDED_AI_ANCHOR=$((ADDED_AI_ANCHOR + 1))
                echo "  Added AI manifest to $mr_6a2_anchor"
            fi
        fi
    fi
done < "$TMPFILE"

rm "$TMPFILE"

echo ""
echo "Summary:"
echo "  Repos with 6a2 directory: $TOTAL"
echo "  Added README.adoc to 6a2/: $ADDED_README_6A2"
echo "  Added AI manifest to 6a2/: $ADDED_AI_6A2"
echo "  Added README.adoc to 6a2/anchor/: $ADDED_README_ANCHOR"
echo "  Added AI manifest to 6a2/anchor/: $ADDED_AI_ANCHOR"
