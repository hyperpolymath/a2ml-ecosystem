#!/bin/bash
# Move converted .a2ml files from .machine_readable/ to .machine_readable/6a2/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
ESTATE_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo "Moving converted .a2ml files to 6a2 directories..."

TOTAL=0
MOVED=0
ALREADY_THERE=0

# Find all .a2ml files in .machine_readable/ but not in 6a2/
cd "$ESTATE_ROOT"
find . -name "*.a2ml" -path "*/.machine_readable/*" ! -path "*/.machine_readable/6a2/*" ! -path "*/.machine_readable/anchors/*" ! -path "*/.machine_readable/6a2/anchor/*" 2>/dev/null | while read a2ml_file; do
    TOTAL=$((TOTAL + 1))
    
    dir=$(dirname "$a2ml_file")
    base=$(basename "$a2ml_file")
    target_dir="$dir/6a2"
    target_file="$target_dir/$base"
    
    # Check if it's one of the core files
    if [[ "$base" =~ ^(STATE|META|ECOSYSTEM|AGENTIC|NEUROSYM|PLAYBOOK)\.a2ml$ ]]; then
        mkdir -p "$target_dir"
        if [ -f "$target_file" ]; then
            ALREADY_THERE=$((ALREADY_THERE + 1))
        else
            mv "$a2ml_file" "$target_file"
            MOVED=$((MOVED + 1))
        fi
    fi
done

echo ""
echo "Summary:"
echo "  Total .a2ml files found: $TOTAL"
echo "  Moved to 6a2/: $MOVED"
echo "  Already in 6a2/: $ALREADY_THERE"
