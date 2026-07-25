<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->
# TOPOLOGY.md — a2ml-haskell

## Purpose

Haskell implementation of the A2ML (Attested Markup Language) parser and renderer. Provides strongly-typed parsing via Haskell's algebraic data types with full parse-render round-trip fidelity. Targets use in template validators, Scaffoldia, and type-heavy tooling.

## Module Map

```
a2ml-haskell/
├── src/
│   ├── Data/             # A2ML AST data types
│   ├── interface/        # Public-facing API surface
│   └── (core, errors, aspects)
├── bench/                # Benchmarks
├── examples/             # Usage examples
├── a2ml-haskell.cabal    # Cabal build config
└── container/            # Containerfile for CI
```

## Data Flow

```
[A2ML text] ──► [Parser] ──► [Haskell ADT AST] ──► [Renderer] ──► [A2ML text]
```
