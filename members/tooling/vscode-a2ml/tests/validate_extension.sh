#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
# validate_extension.sh — Structural tests for vscode-a2ml extension
#
# Validates required VS Code extension assets, package.json fields,
# grammar file structure, and RSR compliance.
#
# Usage: bash tests/validate_extension.sh [repo-root]

set -euo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
PASS=0; FAIL=0

check() {
    local desc="$1"; local path="$2"
    if [ -e "$ROOT/$path" ]; then
        echo "  PASS: $desc"
        ((PASS++)) || true
    else
        echo "  FAIL: $desc — missing $path"
        ((FAIL++)) || true
    fi
}

check_json_field() {
    local desc="$1"; local file="$2"; local field="$3"
    if grep -q "\"$field\"" "$ROOT/$file" 2>/dev/null; then
        echo "  PASS: $desc"
        ((PASS++)) || true
    else
        echo "  FAIL: $desc — field '$field' missing in $file"
        ((FAIL++)) || true
    fi
}

echo "=== vscode-a2ml extension validation ==="
echo ""

# --- Required files ---
echo "--- Required files ---"
check "package.json"                  "package.json"
check "language-configuration.json"  "language-configuration.json"
check "A2ML grammar (tmLanguage)"    "syntaxes/a2ml.tmLanguage.json"
check "Snippets file"                "snippets/a2ml.json"
check "Extension icon (png or svg)"  "icons"

# --- package.json required fields ---
echo ""
echo "--- package.json fields ---"
check_json_field "name field"        "package.json" "name"
check_json_field "displayName field" "package.json" "displayName"
check_json_field "version field"     "package.json" "version"
check_json_field "publisher field"   "package.json" "publisher"
check_json_field "engines field"     "package.json" "engines"
check_json_field "contributes field" "package.json" "contributes"
check_json_field "languages contrib" "package.json" "languages"
check_json_field "grammars contrib"  "package.json" "grammars"

# --- Grammar file validity (JSON parse) ---
echo ""
echo "--- Grammar file validation ---"
if command -v python3 >/dev/null 2>&1; then
    if python3 -c "import json; json.load(open('$ROOT/syntaxes/a2ml.tmLanguage.json'))" 2>/dev/null; then
        echo "  PASS: a2ml.tmLanguage.json is valid JSON"
        ((PASS++)) || true
    else
        echo "  FAIL: a2ml.tmLanguage.json has JSON syntax errors"
        ((FAIL++)) || true
    fi
    if python3 -c "import json; json.load(open('$ROOT/snippets/a2ml.json'))" 2>/dev/null; then
        echo "  PASS: snippets/a2ml.json is valid JSON"
        ((PASS++)) || true
    else
        echo "  FAIL: snippets/a2ml.json has JSON syntax errors"
        ((FAIL++)) || true
    fi
    if python3 -c "import json; json.load(open('$ROOT/language-configuration.json'))" 2>/dev/null; then
        echo "  PASS: language-configuration.json is valid JSON"
        ((PASS++)) || true
    else
        echo "  FAIL: language-configuration.json has JSON syntax errors"
        ((FAIL++)) || true
    fi
else
    echo "  SKIP: python3 not available for JSON validation"
fi

# --- Grammar structural checks ---
echo ""
echo "--- Grammar structural checks ---"
if [ -f "$ROOT/syntaxes/a2ml.tmLanguage.json" ]; then
    if grep -q '"scopeName"' "$ROOT/syntaxes/a2ml.tmLanguage.json"; then
        echo "  PASS: grammar has scopeName"
        ((PASS++)) || true
    else
        echo "  FAIL: grammar missing scopeName"
        ((FAIL++)) || true
    fi
    if grep -q '"patterns"' "$ROOT/syntaxes/a2ml.tmLanguage.json"; then
        echo "  PASS: grammar has patterns"
        ((PASS++)) || true
    else
        echo "  FAIL: grammar missing patterns"
        ((FAIL++)) || true
    fi
fi

# --- Snippet count check ---
echo ""
echo "--- Snippet count ---"
if [ -f "$ROOT/snippets/a2ml.json" ] && command -v python3 >/dev/null 2>&1; then
    count=$(python3 -c "import json; d=json.load(open('$ROOT/snippets/a2ml.json')); print(len(d))" 2>/dev/null || echo "0")
    if [ "$count" -gt 0 ]; then
        echo "  PASS: $count snippet(s) defined"
        ((PASS++)) || true
    else
        echo "  WARN: 0 snippets — add at least one"
    fi
fi

# --- RSR compliance ---
echo ""
echo "--- RSR compliance ---"
check "EXPLAINME.adoc"          "EXPLAINME.adoc"
check "0-AI-MANIFEST.a2ml"     "0-AI-MANIFEST.a2ml"
check "SECURITY.md"            "SECURITY.md"
check "CONTRIBUTING.md or adoc" "CONTRIBUTING.md"

# --- Zig FFI test ---
echo ""
echo "--- Zig FFI ---"
check "Zig integration test"   "src/interface/ffi/test/integration_test.zig"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
