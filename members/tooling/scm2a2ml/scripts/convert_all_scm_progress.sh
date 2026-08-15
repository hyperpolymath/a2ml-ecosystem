#!/bin/bash
# Convert all remaining .scm files to .a2ml with progress tracking

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
# The estate root is two levels up from SCRIPT_DIR (a2ml/scm2a2ml/scripts/ -> a2ml/ -> repos/)
ESTATE_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
CONVERTER="$REPO_ROOT/target/debug/scm2a2ml"

# Get list of all .scm files
SCM_FILES=$(mktemp)
find "$ESTATE_ROOT" -name "*.scm" -path "*/.machine_readable/*" ! -path "*/.machine_readable/6a2/*" 2>/dev/null > "$SCM_FILES"

TOTAL=$(wc -l < "$SCM_FILES")
echo "Found $TOTAL .scm files to convert"

CONVERTED=0
FAILED=0
START_TIME=$(date +%s)

while IFS= read -r scm_file; do
    CONVERTED=$((CONVERTED + 1))
    
    # Show progress every 50 files
    if [ $((CONVERTED % 50)) -eq 0 ] || [ $CONVERTED -eq 1 ] || [ $CONVERTED -eq $TOTAL ]; then
        ELAPSED=$(( $(date +%s) - START_TIME ))
        if [ $ELAPSED -gt 0 ]; then
            RATE=$(( CONVERTED * 60 / ELAPSED ))
            REMAINING=$(( (TOTAL - CONVERTED) * ELAPSED / CONVERTED ))
            echo "[$(date +'%H:%M:%S')] Progress: $CONVERTED/$TOTAL (Rate: ~${RATE}/min, ETA: ${REMAINING}s)"
        else
            echo "[$(date +'%H:%M:%S')] Progress: $CONVERTED/$TOTAL"
        fi
    fi
    
    # Convert the file
    if "$CONVERTER" "$scm_file" --in-place 2>/dev/null; then
        : # Success, continue
    else
        FAILED=$((FAILED + 1))
        echo "  FAILED: $scm_file" >&2
        # Try to continue anyway
    fi
done < "$SCM_FILES"

rm "$SCM_FILES"

ELAPSED=$(( $(date +%s) - START_TIME ))
echo ""
echo "=== Conversion Complete ==="
echo "Total: $TOTAL"
echo "Converted: $((TOTAL - FAILED))"
echo "Failed: $FAILED"
echo "Time: ${ELAPSED}s"

if [ $FAILED -gt 0 ]; then
    echo "WARNING: $FAILED files failed to convert"
    exit 1
fi

exit 0
