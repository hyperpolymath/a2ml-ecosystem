<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# A2ML Ecosystem — Close-Out

Decision ledger for the coordination-hub rebuild.

## Decided

- **Shape.** The hub is a coordination hub plus pinned submodules — a sibling of
  `developer-ecosystem` and a satellite of `hyperpolymath/standards`.
- **Spec home.** The A2ML specification lives in `hyperpolymath/standards`
  (`docs/A2ML-SPEC.adoc`). This hub pins it by tag; it does not own it.
- **Drift model.** Pin + verify: upstream spec and governance are referenced by
  pinned tag and checked in CI, never hard-linked or copied.
- **Members.** 12 members across implementations / tooling / ci / examples,
  pinned as submodule gitlinks on `main`. `contractiles-a2-lab` is excluded
  (private) and only cross-referenced.
- **Governance layout.** Machine-readable metadata lives under
  `.machine_readable/` only; `0-AI-MANIFEST.a2ml` is the root entry point.
- **Conformance verified.** 4 valid + 5 invalid `.a2ml` fixtures, indexed by
  `conformance/manifest.a2ml`: valid validates with 0 errors; invalid (strict)
  errors on every case.

## Issues (filed)

- Pin canonical spec in standards + replace TODO-tag — `decision, governance`
- Member rollout: ANCHOR satellite+pin+conformance CI; enable upstream-pins — `rollout`
- Canonical parse-AST (expected.json) + expand conformance corpus — `conformance`
- Governance parity: stamp standard `.machine_readable` + CONTRIBUTING/SECURITY/COC from standards — `governance`
- Author tiered dev/maintainer/user docs + concept guides — `docs`
- Reference this hub from developer-ecosystem / standards — `meta`
- Ratify a2mliser (in) + contractiles-a2-lab (cross-ref) — `decision`

## Discarded

- Bundling member sources into the hub (rejected: members stay independent).
- WSL-specific tooling assumptions (rejected: not portable).
- base64-embedded payloads for fixtures or metadata (rejected: opaque and
  unverifiable).

## Cleanup

- After the PR merges, delete the development branch
  `claude/gracious-goodall-4vnq77`.
