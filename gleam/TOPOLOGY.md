<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- (MPL-2.0 preferred; MPL-2.0 required for Hex.pm) -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->

# TOPOLOGY.md — a2ml_gleam

## Purpose

A pure Gleam library for parsing, manipulating, and rendering A2ML (AI Attestation Markup Language) documents. Provides full A2ML parser with error reporting, manifest extraction, and roundtrip fidelity for trust-level handling.

## Module Map

```
a2ml_gleam/
├── src/
│   ├── a2ml/
│   │   ├── parser.gleam       # Recursive descent parser, error recovery
│   │   ├── renderer.gleam     # AST → A2ML text output
│   │   └── manifest.gleam     # Directive extraction and queries
│   └── a2ml.gleam             # Module entry point
├── test/
│   └── a2ml_gleam_test.gleam  # Parser/renderer roundtrip tests
└── gleam.toml                  # Hex package metadata
```

## Data Flow

```
[A2ML Text] ──► [Parser] ──► [AST] ──► [Renderer] ──► [A2ML Text]
                                ↓
                          [Manifest Extract]
```

## Key Invariants

- Roundtrip fidelity: parse + render preserves document structure
- Error recovery: malformed directives return errors, don't crash
- Trust-level validation: structural only (enum values), cryptographic verification external
