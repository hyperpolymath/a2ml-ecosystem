<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->
# TOPOLOGY.md — a2ml_ex

## Purpose

Elixir implementation of the A2ML (Attested Markup Language) parser and renderer. Provides a complete parse-render round-trip for A2ML documents using native Elixir structs. Intended for integration with Phoenix/BEAM applications and Elixir toolchains.

## Module Map

```
a2ml_ex/
├── lib/
│   ├── a2ml/
│   │   ├── core/         # Parser core logic
│   │   ├── errors/       # Error structs
│   │   ├── aspects/      # Cross-cutting concerns
│   │   └── (bridges, contracts, definitions)
│   └── a2_ml.ex          # Top-level module entry point
├── mix.exs               # Mix project config
└── deps/                 # Dependencies
```

## Data Flow

```
[A2ML text] ──► [A2ML.Parser] ──► [Typed structs] ──► [A2ML.Renderer] ──► [A2ML text]
```
