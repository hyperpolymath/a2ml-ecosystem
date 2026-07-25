# Security Policy

<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) -->

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.x.x   | :white_check_mark: |

## Reporting a Vulnerability

**Do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via:

1. **Email**: security@hyperpolymath.org (preferred)
2. **GitHub Security Advisories**: [Create a private advisory](https://github.com/hyperpolymath/a2ml_ex/security/advisories/new)

### What to include

- Type of vulnerability (injection, deserialization, etc.)
- Full path to affected source file(s)
- Step-by-step instructions to reproduce
- Proof-of-concept or exploit code (if available)
- Impact assessment

### Response Timeline

- **Acknowledgment**: Within 48 hours
- **Initial assessment**: Within 7 days
- **Resolution target**: Within 90 days (may vary based on severity)

### Safe Harbor

We consider security research conducted in accordance with this policy to be:
- Authorized
- Lawful
- Helpful

We will not pursue legal action against researchers who follow this policy.

## Security Measures

This project implements:

- [x] Dependabot alerts enabled
- [x] CodeQL static analysis
- [x] OpenSSF Scorecard compliance
- [x] Signed commits required
- [x] Branch protection enabled
- [x] Zero runtime dependencies beyond Elixir standard library

## Known Limitations

The A2ML parser processes untrusted input. While the Elixir implementation
benefits from BEAM VM memory safety:

1. **Parser input** may contain maliciously crafted documents
2. **Directive evaluation** does not execute arbitrary code
3. **Trust level assertions** are metadata only — they do not provide cryptographic guarantees without external verification

Report issues in any layer — we take all security concerns seriously.
