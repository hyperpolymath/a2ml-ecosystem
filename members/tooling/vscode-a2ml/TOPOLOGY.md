<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- (MPL-2.0 preferred; MPL-2.0 required for VS Code marketplace) -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->
# TOPOLOGY.md — vscode-a2ml

## Purpose

VS Code extension providing syntax highlighting, language configuration, and snippets for A2ML (AI-to-Machine Language) files. Enables editor support for `.a2ml` manifests used across RSR repos. Published to the VS Code marketplace (MPL-2.0 required by platform).

## Module Map

```
vscode-a2ml/
├── syntaxes/                    # TextMate grammar for A2ML syntax highlighting
├── snippets/                    # Code snippets for common A2ML patterns
├── src/                         # Extension TypeScript entry point (marketplace req)
├── icons/                       # File type icons
├── language-configuration.json  # Bracket matching, comment config
├── package.json                 # VS Code extension manifest
└── docs/                        # Extension documentation
```

## Data Flow

```
[.a2ml file opened] ──► [syntaxes/ grammar] ──► [syntax highlighting]
                   └──► [snippets/]          ──► [completions]
                   └──► [language-config]    ──► [bracket/comment behaviour]
```
