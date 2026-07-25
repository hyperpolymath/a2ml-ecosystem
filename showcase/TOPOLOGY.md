<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->
# TOPOLOGY.md — a2ml-showcase

## Purpose

Content showcase for A2ML (AI Attestation Markup Language): example documents, templates, and rendered output demonstrating A2ML format capabilities. No executable code — pure content and documentation repo. Generated output is produced by the Deno renderer via `just render`.

## Module Map

```
a2ml-showcase/
├── content/       # A2ML source documents (examples, templates)
├── output/        # Rendered output (HTML, text)
├── deno.json      # Deno task runner config
└── template.html  # HTML rendering template
```

## Data Flow

```
[content/*.a2ml] ──► [a2ml-deno renderer] ──► [output/]
```
