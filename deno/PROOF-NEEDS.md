# Proof Requirements

## Current state
- ABI directory exists (template-level)
- No dangerous patterns found
- 2.2K lines; ReScript-based A2ML parser with trust-level hierarchy

## What needs proving
- **Trust-level ordering**: Prove the trust hierarchy (Unverified < Automated < Reviewed < Verified) forms a total order and that attestation operations never silently upgrade trust level
- **Parser round-trip**: Prove parse-then-render produces semantically equivalent A2ML (no silent attribute loss)
- **Attestation chain validity**: Prove attestation chains cannot be forged or reordered without detection

## Recommended prover
- **Idris2** — Trust-level lattice is a natural fit for dependent types with `DecEq` and `Ord` proofs

## Priority
- **LOW** — A2ML is a markup format, not safety-critical infrastructure. However, if attestation trust levels are relied upon by downstream security decisions (e.g., Hypatia), the trust-level ordering proof becomes MEDIUM priority.

## Template ABI Cleanup (2026-03-29)

Template ABI removed -- was creating false impression of formal verification.
The removed files (Types.idr, Layout.idr, Foreign.idr) contained only RSR template
scaffolding with unresolved {{PROJECT}}/{{AUTHOR}} placeholders and no domain-specific proofs.
