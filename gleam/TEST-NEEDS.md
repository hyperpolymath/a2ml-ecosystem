# TEST-NEEDS — a2ml_gleam

<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- (MPL-2.0 preferred; MPL-2.0 required for Hex.pm) -->

## CRG Grade: C — ACHIEVED 2026-04-04

## CRG C — Test Coverage Achieved

CRG C gate requires: unit, smoke, build, P2P (property-based), E2E,
reflexive, contract, aspect, and benchmark tests.

| Category      | File                                    | Count | Notes                                       |
|---------------|-----------------------------------------|-------|---------------------------------------------|
| Unit          | `test/a2ml_gleam_test.gleam`            | 12    | Parser, renderer, trust levels, attestation |
| Smoke         | `test/a2ml_gleam_test.gleam`            | —     | Covered by minimal parse/render tests       |
| Build         | `gleam build`                           | —     | CI gate                                     |
| Property/P2P  | `test/a2ml_gleam_property_test.gleam`   | 6     | Determinism, roundtrip, invalid input loops |
| E2E           | `test/a2ml_gleam_test.gleam`            | 1     | Full parse/render/re-parse roundtrip        |
| Reflexive     | `test/a2ml_gleam_property_test.gleam`   | 1     | Trust level string roundtrip identity       |
| Contract      | `test/a2ml_gleam_contract_test.gleam`   | 12    | Named invariants (error/ok guarantees)      |
| Aspect        | `test/a2ml_gleam_aspect_test.gleam`     | 13    | Security, correctness, performance, resilience |
| Benchmark     | `test/a2ml_gleam_bench_test.gleam`      | 5     | Bulk operation correctness guards           |

**Total: 50 tests, 0 failures**

## Running Tests

```bash
gleam test
```

## Test Taxonomy (Testing Taxonomy v1.0)

- **Unit**: individual function correctness
- **Smoke**: essential path does not crash
- **Build**: compilation gate (gleam build)
- **Property/P2P**: determinism, algebraic laws, invariants over many inputs
- **E2E**: full parse → render → re-parse pipeline
- **Reflexive**: trust level string roundtrip identity laws
- **Contract**: named behavioural invariants (error-shape guarantee, etc.)
- **Aspect**: cross-cutting concerns (security input safety, performance bounds, resilience)
- **Benchmark**: bulk operation correctness guards (Gleam has no wall-clock assert harness)

## Remaining Gaps (Future Work)

- Real fuzz harness (the `tests/fuzz/placeholder.txt` is a scorecard placeholder only)
- Cross-implementation compatibility tests vs a2ml_ex and a2ml-rs
- BEAM vs JS target performance comparison
