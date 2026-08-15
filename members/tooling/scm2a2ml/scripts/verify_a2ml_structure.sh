#!/bin/bash
# Verification script for A2ML structure compliance

set -euo pipefail

PASS=0
FAIL=0

check() {
    local description="$1"
    local test="$2"
    if eval "$test" >/dev/null 2>&1; then
        echo "  ✅ $description"
        PASS=$((PASS + 1))
    else
        echo "  ❌ $description"
        FAIL=$((FAIL + 1))
    fi
}

get_git_repos() {
    find . -name ".git" -type d -printf '%h\n' | sort -u
}

echo "========================================"
echo "A2ML Structure Verification"
echo "========================================"
echo ""

# Test 1: No .scm files in .machine_readable root
echo "Test 1: No .scm files in .machine_readable root"
SCM_COUNT=$(get_git_repos | while read repo; do 
    for f in STATE.scm META.scm ECOSYSTEM.scm AGENTIC.scm NEUROSYM.scm PLAYBOOK.scm; do
        [ -f "$repo/.machine_readable/$f" ] && echo "found" && break
    done
done | wc -l)
check "No .scm files found" "[ $SCM_COUNT -eq 0 ]"
echo ""

# Test 2: No anchor files in old locations
echo "Test 2: No anchor files in old locations"
ANCHOR_OLD=$(get_git_repos | while read repo; do 
    [ -f "$repo/.machine_readable/anchors/ANCHOR.a2ml" ] && echo "found"
    [ -f "$repo/.machine_readable/6a2/ANCHOR.a2ml" ] && echo "found"
done | wc -l)
check "No anchor files in old locations" "[ $ANCHOR_OLD -eq 0 ]"
echo ""

# Test 3: All anchor files in correct location
echo "Test 3: Anchor files in 6a2/anchor/"
ANCHOR_NEW=$(get_git_repos | while read repo; do 
    [ -f "$repo/.machine_readable/6a2/anchor/ANCHOR.a2ml" ] && echo "found"
done | wc -l)
check "Anchor files in 6a2/anchor/" "[ $ANCHOR_NEW -gt 270 ]"
echo ""

# Test 4: README.adoc exists in 6a2 directories
echo "Test 4: README.adoc in 6a2 directories"
README_6A2_MISSING=$(get_git_repos | while read repo; do 
    [ -d "$repo/.machine_readable/6a2" ] && [ ! -f "$repo/.machine_readable/6a2/README.adoc" ] && echo "$repo"
done | wc -l)
check "All 6a2 dirs have README.adoc" "[ $README_6A2_MISSING -eq 0 ]"
echo ""

# Test 5: AI manifest exists in 6a2 directories
echo "Test 5: AI manifest in 6a2 directories"
AI_6A2_MISSING=$(get_git_repos | while read repo; do 
    [ -d "$repo/.machine_readable/6a2" ] && [ ! -f "$repo/.machine_readable/6a2/0-AI-MANIFEST.a2ml" ] && [ ! -f "$repo/.machine_readable/6a2/AI-MANIFEST.a2ml" ] && echo "$repo"
done | wc -l)
check "All 6a2 dirs have AI manifest" "[ $AI_6A2_MISSING -eq 0 ]"
echo ""

# Test 6: No duplicate core files
echo "Test 6: No duplicate core A2ML files"
DUPLICATES=$(get_git_repos | while read repo; do 
    for file in STATE META ECOSYSTEM AGENTIC NEUROSYM PLAYBOOK; do
        count=$(find "$repo/.machine_readable" -name "${file}.a2ml" 2>/dev/null | wc -l)
        if [ $count -gt 1 ]; then
            echo "$repo"
            break
        fi
    done
done | wc -l)
check "No duplicate core files" "[ $DUPLICATES -eq 0 ]"
echo ""

# Test 7: Directory structure exists
echo "Test 7: Required directory structure"
TOTAL_REPOS=$(get_git_repos | wc -l)
STRUCT_OK=$(get_git_repos | while read repo; do 
    [ -d "$repo/.machine_readable" ] && [ -d "$repo/.machine_readable/6a2" ] && echo "$repo"
done | wc -l)
check "All repos have .machine_readable/6a2/" "[ $STRUCT_OK -eq $TOTAL_REPOS ]"
echo ""

# Summary
echo "========================================"
echo "Verification Summary"
echo "========================================"
echo "  Passed: $PASS"
echo "  Failed: $FAIL"
echo ""

if [ $FAIL -gt 0 ]; then
    echo "❌ VERIFICATION FAILED"
    exit 1
else
    echo "✅ VERIFICATION PASSED"
    exit 0
fi
