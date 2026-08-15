# TEST-NEEDS.md — vscode-a2ml

## CRG Grade: C — ACHIEVED 2026-04-04

## Current Test State

| Category | Count | Notes |
|----------|-------|-------|
| Test infrastructure | Present | `tests/` directory structure |
| FFI tests | Present | `src/interface/ffi/test/` |
| Verification tests | Present | `verification/tests/` |
| Aspect modules | Present | `src/aspects/` |

## What's Covered

- [x] Test framework infrastructure
- [x] FFI verification layer
- [x] Aspect-based organization

## Still Missing (for CRG B+)

- [ ] A2ML language syntax tests
- [ ] VSCode extension integration tests
- [ ] Highlighting tests
- [ ] Performance benchmarks
- [ ] End-to-end editor tests

## Run Tests

```bash
cd /var/mnt/eclipse/repos/vscode-a2ml && npm test
```
