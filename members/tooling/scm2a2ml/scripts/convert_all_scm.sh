#!/bin/bash
# Convert all remaining .scm files to .a2ml using scm2a2ml

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CONVERTER="$REPO_ROOT/target/debug/scm2a2ml"

echo "Converting all .scm files to .a2ml..."

# Find all .scm files in .machine_readable directories (excluding 6a2)
find . -name "*.scm" -path "*/.machine_readable/*" ! -path "*/.machine_readable/6a2/*" 2>/dev/null | while read scm_file; do
    echo "Converting: $scm_file"
    
    # Get the directory
    dir=$(dirname "$scm_file")
    
    # Run the converter in-place
    "$CONVERTER" "$scm_file" --in-place -v
    
    echo "  Done"
done

echo "All .scm files converted!"
