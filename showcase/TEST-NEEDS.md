# CRG Grade C Test Coverage

## CRG Grade: B — ACHIEVED 2026-04-04

> CRG B achieved 2026-04-04: Validated A2ML manifests from 6 diverse external repos + ran 18 internal tests.

## CRG B Evidence — External Targets

| Target Repo | A2ML File | What Was Tested | Result |
|-------------|-----------|-----------------|--------|
| gossamer | 0-AI-MANIFEST.a2ml | Structural compliance (8 required fields) | SCORE 8/8 (106 lines, 4851B) |
| boj-server | 0-AI-MANIFEST.a2ml | Structural compliance (8 required fields) | SCORE 8/8 (110 lines, 5036B) |
| echidna | 0-AI-MANIFEST.a2ml | Structural compliance (8 required fields) | SCORE 3/8 (103 lines, 4507B) |
| panic-attacker | 0-AI-MANIFEST.a2ml | Structural compliance (8 required fields) | SCORE 4/8 (119 lines, 4007B) |
| hypatia | 0-AI-MANIFEST.a2ml | Structural compliance (8 required fields) | SCORE 8/8 (117 lines, 5295B) |
| standards | 0-AI-MANIFEST.a2ml | Structural compliance (8 required fields) | SCORE 1/8 (128 lines, 4383B) |

### Compliance fields checked

1. `SPDX-License-Identifier` header
2. `(manifest ...)` wrapper
3. `(identity ...)` section
4. `(purpose ...)` section
5. `(name ...)` field
6. `(version ...)` field
7. `(context ...)` tiers
8. `(canonical ...)` locations

### Target Details

**1. gossamer (Gleam/Rust — window manager)**
- File: `/var/mnt/eclipse/repos/gossamer/0-AI-MANIFEST.a2ml`
- Result: FULL COMPLIANCE. All 8 structural fields present. Proper S-expression format with identity, purpose, context-tiers, canonical-locations, and invariants.

**2. boj-server (ReScript/Deno — MCP server)**
- File: `/var/mnt/eclipse/repos/boj-server/0-AI-MANIFEST.a2ml`
- Result: FULL COMPLIANCE. All 8 structural fields present. Well-structured manifest with 110 lines.

**3. echidna (Rust — theorem prover)**
- File: `/var/mnt/eclipse/repos/verification-ecosystem/echidna/0-AI-MANIFEST.a2ml`
- Result: INCOMPLETE (3/8). Has SPDX and context/canonical but uses non-standard structure missing (manifest), (identity), (purpose), (name), (version) wrappers. Needs migration to standard A2ML format.

**4. panic-attacker (Rust — security scanner)**
- File: `/var/mnt/eclipse/repos/games-ecosystem/panic-attacker/0-AI-MANIFEST.a2ml`
- Result: INCOMPLETE (4/8). Has SPDX, (manifest), version, canonical but missing (identity), (purpose), (name) sections. Partially migrated format.

**5. hypatia (Elixir/Rust — CI/CD scanner)**
- File: `/var/mnt/eclipse/repos/verification-ecosystem/hypatia/0-AI-MANIFEST.a2ml`
- Result: FULL COMPLIANCE. All 8 structural fields present. 117 lines with comprehensive context tiers.

**6. standards (Mixed — multi-standard monorepo)**
- File: `/var/mnt/eclipse/repos/developer-ecosystem/standards/0-AI-MANIFEST.a2ml`
- Result: MINIMAL (1/8). Large file (128 lines, 4383B) but uses legacy format without standard S-expression structure. Only canonical locations present. Needs full rewrite.

### Internal test suite also passing

All 18 internal tests pass (Unit: 4, Smoke: 3, Contract: 2, Aspect: 3, Property: 2, E2E: 2, Benchmark: 2).

**Repository:** a2ml-showcase  
**Grade:** C  
**Last Updated:** 2026-04-04

## Overview

This repository contains A2ML showcase examples and documentation. As a data/showcase repository with no executable code, tests focus on:
- Valid A2ML example structure
- Consistency of formatting
- Completeness of required fields
- Documentation accuracy

## Test Categories

| Category | Count | Status | Notes |
|----------|-------|--------|-------|
| Unit Tests | 4 | ✓ PASS | File existence, structure, SPDX headers, content files |
| Smoke Tests | 3 | ✓ PASS | A2ML syntax, attestation blocks, policy blocks |
| Contract Tests | 2 | ✓ PASS | Required A2ML fields, valid trust levels |
| Aspect Tests | 3 | ✓ PASS | Agent naming, formatting consistency, SPDX consistency |
| Property-Based Tests | 2 | ✓ PASS | Agent-id declarations, trust level progression |
| E2E/Reflexive Tests | 2 | ✓ PASS | Attestation parsing, reference resolution |
| Benchmarks | 2 | ✓ PASS | File read performance, example count baseline |

**Total Test Count:** 18  
**All Tests Passing:** Yes

## Running Tests

```bash
deno test tests/validate.test.ts
```

## Test Details

### Unit Tests (4)
- Validates all required example files exist
- Checks for SPDX license headers in examples
- Verifies content structure has expected sections
- Confirms markdown files are readable

### Smoke Tests (3)
- Verifies @attestation blocks are syntactically valid
- Checks @policy blocks are present and formatted
- Validates README cross-references

### Contract Tests (2)
- Every attestation must have: agent-id, attested-by, trust-level
- Trust levels must be one of: self-declared, verified, audited

### Aspect Tests (3)
- Agent IDs follow naming convention (lowercase-alphanumeric-hyphens)
- @attestation/@end blocks are balanced
- SPDX headers are consistent across documentation

### Property-Based Tests (2)
- Every declared agent-id must appear in at least one attestation
- Documentation includes all three trust level progression stages

### E2E/Reflexive Tests (2)
- A2ML attestation blocks can be parsed into key-value pairs
- All numbered references [1], [2], etc. are cited in text

### Benchmarks (2)
- File read operations complete in < 100ms
- Contains expected number of documented examples (≥ 3)

## Dependencies

- Deno 1.40+
- deno_std (assert module)

## Future Enhancements

- [ ] Add schema validation against formal A2ML grammar
- [ ] Validate agent capabilities against registry
- [ ] Check timestamp formats (RFC3339)
- [ ] Verify signature formats
