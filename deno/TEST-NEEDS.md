# Test & Benchmark Requirements

## CRG Grade: C — ACHIEVED 2026-04-04

## Current State
- Unit tests: NONE (no Deno/ReScript test files found)
- Integration tests: 1 Zig integration test (ABI/FFI template)
- E2E tests: NONE
- Benchmarks: NONE (benchmark dir has only README placeholder)
- panic-attack scan: NEVER RUN (feature dir exists but no report)

## What's Missing
### Point-to-Point (P2P)
- A2ML.res — no tests
- A2ML_Types.res — no tests
- A2ML_Parser.res — no tests
- A2ML_Renderer.res — no tests
- Zig FFI main.zig — only template integration test
- Idris2 ABI definitions (Types.idr, Layout.idr, Foreign.idr) — no verification tests

### End-to-End (E2E)
- Parse A2ML document and verify output — not tested
- Render A2ML to output format — not tested
- Round-trip (parse then render) fidelity — not tested
- Error handling for malformed A2ML — not tested
- Deno runtime integration — not tested

### Aspect Tests
- [ ] Security (input sanitisation for untrusted A2ML documents)
- [ ] Performance (parsing large A2ML documents)
- [ ] Concurrency (N/A for parser library)
- [ ] Error handling (malformed input, missing fields, invalid trust levels)
- [ ] Accessibility (N/A)

### Build & Execution
- [ ] deno check — not verified
- [ ] deno test — not verified
- [ ] ReScript build — not verified
- [ ] Zig build — not verified
- [ ] Self-diagnostic — none

### Benchmarks Needed
- Parse throughput vs a2ml-rs and a2ml_ex implementations
- Memory usage on large documents
- Zig FFI call overhead measurement

### Self-Tests
- [ ] panic-attack assail on own repo
- [ ] Built-in doctor/check command (if applicable)

## Priority
- **HIGH** — A2ML is a critical format in the ecosystem. 4 ReScript source files + 3 Idris2 ABI + 2 Zig FFI files with ZERO functional tests. The fuzz directory contains only a placeholder.txt. As a library consumed by other projects, this needs comprehensive tests.
