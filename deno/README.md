<!--
SPDX-License-Identifier: CC-BY-SA-4.0
SPDX-FileCopyrightText: 2025-2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->

# Overview

**Deno-native parser library for A2ML (Attested Markup Language),
written in ReScript.**

A2ML is a structured markup language with built-in attestation
provenance, directive metadata, and trust-level tracking. This library
provides a complete parser and renderer for A2ML documents, compiled
from ReScript to JavaScript ES modules for use with Deno.

# Features

- Parse A2ML documents from strings or files

- Render AST back to A2ML surface syntax (round-trip support)

- Typed AST with variant types for blocks, inlines, directives, and
  attestations

- Trust-level hierarchy: Unverified, Automated, Reviewed, Verified

- Directive blocks with key-value attributes

- Attestation provenance chain

- Zero dependencies beyond ReScript standard library

# Quick Start

```bash
# Build ReScript to JS
deno task build

# Use in your Deno project
deno add jsr:@hyperpolymath/a2ml
```

```javascript
import { parse, render, parseErrorToString } from "@hyperpolymath/a2ml";

const result = parse("# Hello World\n\nSome **bold** text.\n");
// result is Ok(document) or Error(parseError)
```

# Module Structure

| Module | Purpose |
|----|----|
| `A2ML.res` | Main module — re-exports all public API |
| `A2ML_Types.res` | Core data types: document, block, inline, directive, attestation, trustLevel |
| `A2ML_Parser.res` | Line-oriented parser: A2ML text to typed AST |
| `A2ML_Renderer.res` | Renderer: typed AST back to A2ML text |

# A2ML Syntax Reference

    # Heading

    Paragraph with **bold**, *italic*, `code`, [link](url), and @ref(id).

    @directive-name(key=val): single line value

    @multi-line:
    Content spanning
    multiple lines
    @end

    !attest
    identity: Jonathan D.A. Jewell
    role: author
    trust-level: verified
    timestamp: 2026-03-16T00:00:00Z
    !end

    - Bullet list item
    - Another item

    > Block quote text

    ```rescript
    let x = 42
    ```

# Development

```bash
deno task build    # Compile ReScript
deno task clean    # Clean build artifacts
deno task test     # Run tests
```

# Related Libraries

- [a2ml-rs](https://github.com/hyperpolymath/a2ml-rs) — Rust
  implementation

- [a2ml-haskell](https://github.com/hyperpolymath/a2ml-haskell) —
  Haskell implementation

- [a2ml_gleam](https://github.com/hyperpolymath/a2ml_gleam) — Gleam
  implementation

- [tree-sitter-a2ml](https://github.com/hyperpolymath/tree-sitter-a2ml)
  — Tree-sitter grammar

- [vscode-a2ml](https://github.com/hyperpolymath/vscode-a2ml) — VS Code
  extension

# License

SPDX-License-Identifier: CC-BY-SA-4.0

Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath)

See [LICENSE](LICENSE) for details.
