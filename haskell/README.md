<!--
SPDX-License-Identifier: CC-BY-SA-4.0
SPDX-FileCopyrightText: 2025-2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->

Haskell library for parsing and rendering A2ML (Attested Markup
Language) — attestation-native markup carrying trust metadata,
cryptographic attestation fields, and provenance information.

# Overview

`a2ml-haskell` provides a purely functional parser and renderer over
`Text`:

- `Data.A2ML.Parser` — \`parseA2ML  
  Text → Either ParseError Document\`. Line-oriented, no regex, no
  mutable state. Recognises headings, multi-line directive blocks
  (`@name:` `…` `@end`), bullet lists, and inline formatting.

- `Data.A2ML.Renderer` — serialises a `Document` back to canonical A2ML.

<!-- -->

- `Data.A2ML.Types` — `Document`, `Block`, `Inline`, `DirectiveName`
  (typed sum: `DirAbstract`, `DirRefs`, `DirAttestation`, `DirMeta`,
  `DirCustom` `Text`), `Attestation`, `TrustLevel`, `Manifest`,
  `Reference`.

The Haskell variant uses richer directive syntax than `a2ml-rs`:
directives are multi-line `@name:` `…` `@end` blocks (not single-line
`@name` `value` pairs).

# Attestation Model

The `Attestation` type carries:

- `attestationSigner` — identity of the signing agent or person

- `attestationAlgorithm` — e.g. `"ed25519"` or `"sha256"`

- `attestationSignature` — hex or base64 signature (opaque, not verified
  here)

- `attestationTimestamp` — optional ISO-8601 timestamp

`TrustLevel` encodes attestor count and independence: `Unsigned` →
`SelfAttested` → `ThirdPartyAttested` → `MultiAttested`.

`Manifest` aggregates title, author, version, SPDX license, overall
trust level, and the full attestation list — the entry point for
provenance inspection.

# Building

```sh
cabal build
cabal test
```

# Related

- [a2ml-rs](https://github.com/hyperpolymath/a2ml-rs) — Rust
  implementation

- [pandoc-a2ml](https://github.com/hyperpolymath/pandoc-a2ml) — Pandoc
  Lua reader/writer

# License

MPL-2.0. See [LICENSE](LICENSE).
