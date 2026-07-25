<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->
# TOPOLOGY.md — a2ml-rs

## Purpose

Rust parser and renderer for A2ML (Attested Markup Language), a structured markup format with built-in attestation provenance, directive metadata, and trust-level tracking. Provides a complete parse-render round-trip with typed AST. Intended for use in CI tooling, validators, and server-side pipelines.

## Module Map

```
a2ml-rs/
├── src/
│   ├── lib.rs         # Public crate API
│   ├── types.rs       # AST types (blocks, inlines, directives, attestations)
│   ├── parser.rs      # A2ML document parser
│   ├── renderer.rs    # AST-to-A2ML surface syntax renderer
│   └── error.rs       # Error types
├── benches/           # Criterion benchmarks
├── examples/          # Usage examples
├── Cargo.toml
└── container/         # Containerfile for CI
```

## Data Flow

```
[A2ML text] ──► [parser.rs] ──► [Typed AST] ──► [renderer.rs] ──► [A2ML text]
                                     │
                              [types.rs / error.rs]
```
