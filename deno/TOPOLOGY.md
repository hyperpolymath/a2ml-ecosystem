<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->
# TOPOLOGY.md — a2ml-deno

## Purpose

Deno-native parser and renderer for A2ML (Attested Markup Language), written in ReScript and compiled to JavaScript ES modules. Provides parse-render round-trip support for A2ML documents with trust-level hierarchy and directive blocks. Consumed by Deno runtimes and published to JSR.

## Module Map

```
a2ml-deno/
├── src/
│   ├── A2ML.res           # Main public API
│   ├── A2ML_Types.res     # AST types (ReScript variants)
│   ├── A2ML_Parser.res    # Document parser
│   ├── A2ML_Renderer.res  # AST-to-surface renderer
│   └── (compiled .mjs files co-located)
├── examples/              # Usage examples
├── deno.json              # Deno module config
├── jsr.json               # JSR publication config
└── container/             # Containerfile for CI
```

## Data Flow

```
[A2ML text] ──► [A2ML_Parser] ──► [Typed AST] ──► [A2ML_Renderer] ──► [A2ML text]
                                        │
                                  [A2ML_Types]
```
