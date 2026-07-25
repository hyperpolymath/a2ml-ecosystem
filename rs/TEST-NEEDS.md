# Test & Benchmark Requirements

## CRG Grade: C — ACHIEVED 2026-04-04

## Current State
- Unit tests: 14 pass / 0 fail (11 unit + 3 doc-tests)
- Integration tests: NONE
- E2E tests: NONE
- Benchmarks: NONE (benchmark dir has only README placeholder)
- panic-attack scan: NEVER RUN (feature dir exists but no report)

## What's Missing
### Point-to-Point (P2P)
- lib.rs — 11 inline tests exist, reasonable for module size
- parser.rs — tests exist but edge cases likely missing (malformed input, unicode, deeply nested structures)
- renderer.rs — likely untested or minimally tested
- types.rs — likely untested
- error.rs — error paths and formatting not tested
- tests/fuzz/ contains only placeholder.txt — no fuzzing

### End-to-End (E2E)
- Parse real-world A2ML files from other hyperpolymath repos
- Round-trip (parse -> render -> parse) equality check
- Cross-implementation compatibility with a2ml_ex, a2ml_gleam, a2ml-haskell
- CLI integration if binary exists

### Aspect Tests
- [ ] Security (untrusted A2ML input, DoS via deeply nested structures)
- [ ] Performance (large document parsing)
- [ ] Concurrency (N/A for library)
- [ ] Error handling (all error.rs variants reachable and tested)
- [ ] Accessibility (N/A)

### Build & Execution
- [x] cargo build — clean
- [x] cargo test — 14 pass, 0 fail
- [ ] Self-diagnostic — none

### Benchmarks Needed
- Parse throughput (Criterion benchmarks)
- Memory allocation profile
- Comparison vs a2ml_ex (BEAM) and a2ml-deno (V8)

### Self-Tests
- [ ] panic-attack assail on own repo
- [ ] Built-in doctor/check command (if applicable)

## Priority
- **MEDIUM** — 5 source files with 14 tests is decent ratio but renderer and types likely lack coverage. Fuzz directory is empty. No benchmarks despite benchmark dir existing. As the Rust reference implementation, this should have the most comprehensive tests of all A2ML libraries.

## Session 9 additions (2026-04-04)

### What Was Added

| Area | Tests Added | Location |
|------|-------------|----------|
| Benchmarks | Extended `benches/a2ml_bench.rs` with `attestation_benches` group: 4 functions: `bench_parse_attestation_heavy`, `bench_parse_directive_heavy`, `bench_attestation_access`, `bench_render_attestation_heavy` | `benches/a2ml_bench.rs` |

### Updated Test Counts

| Suite | Count | Status |
|-------|-------|--------|
| Benchmarks (attestation) | 4 new | Added to attestation_benches group |
