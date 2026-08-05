<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->

# REQUIRES INITIALISATION

**This repository is not finished being set up.** 37 substitution token(s) across 55 file(s) still have no value.

## Why this is not already done

This repo was created from `hyperpolymath/rsr-template-repo`. The mint
(`just repo-init`) fills every token that has a single mechanical answer —
owner, repo, author, dates, licence, branch — and it has done so here.

The tokens below are the ones it *deliberately cannot* answer. They need a
decision or a fact that exists only in your head: what this project is for,
what command builds it, which port the service listens on, whether a PGP key
is held at all. The template's own token vocabulary says as much — you cannot
sensibly answer "required invariants" in a thirty-second bootstrap.

They were left **visibly unfilled on purpose**. The alternatives were both
worse: inventing plausible values would put confident falsehoods into a
security policy and an architecture document, and silently deleting the
sections would hide the fact that a decision is owed. A visible gap is
honest; a fabricated answer is not.

## Do not delete this file until every item below is resolved

This file is the only marker that the work is outstanding. Deleting it early
does not finish the setup, it just conceals it — and the next person or agent
to arrive will reasonably assume the repo is complete.

- **If you are a person:** delete this file yourself once the last item is done.
- **If you are an agent:** resolve what you legitimately can, leave the rest,
  and delete this file only when no token below remains anywhere in the tree.
  Do not delete it to make a gate go green.

Re-running the estate top-up tool will remove this file automatically once
nothing is outstanding, so the safest way to finish is to fix the tokens and
let the check confirm it.

## What is needed, and where it goes

### `{{AUTHOR_EMAIL_ALT}}`

Appears in:

- `deno/.machine_readable/ai/PLACEHOLDERS.adoc`
- `haskell/.machine_readable/ai/PLACEHOLDERS.adoc`
- `rs/.machine_readable/ai/PLACEHOLDERS.adoc`

### `{{AUTHOR_ORG}}`

Author's organisation. NOTE: no filled instance of this exists anywhere in the estate — consider deleting the field instead.

Appears in:

- `deno/.machine_readable/ai/PLACEHOLDERS.adoc`
- `deno/.machine_readable/svc/k9/examples/project-metadata.k9.ncl`
- `rs/.machine_readable/ai/PLACEHOLDERS.adoc`
- `rs/.machine_readable/svc/k9/examples/project-metadata.k9.ncl`

### `{{CONDUCT_TEAM}}`

Name of the conduct body. If there is no committee, rewrite the sentence rather than substituting a plural noun into 'a {{CONDUCT_TEAM}} member'.

Appears in:

- `deno/.machine_readable/ai/PLACEHOLDERS.adoc`
- `rs/.machine_readable/ai/PLACEHOLDERS.adoc`

### `{{CONSUMER1}}`

A downstream repo that consumes this one.

Appears in:

- `deno/.machine_readable/INTENT.contractile`
- `ex/.machine_readable/INTENT.contractile`
- `gleam/.machine_readable/INTENT.contractile`
- `haskell/.machine_readable/INTENT.contractile`
- `rs/.machine_readable/INTENT.contractile`
- `showcase/.machine_readable/INTENT.contractile`

### `{{CONSUMER2}}`

A second downstream consumer.

Appears in:

- `deno/.machine_readable/INTENT.contractile`
- `ex/.machine_readable/INTENT.contractile`
- `gleam/.machine_readable/INTENT.contractile`
- `haskell/.machine_readable/INTENT.contractile`
- `rs/.machine_readable/INTENT.contractile`
- `showcase/.machine_readable/INTENT.contractile`

### `{{COST_CEILING_POLICY}}`

Appears in:

- `validate-action/.machine_readable/contractiles/trust/Trustfile.a2ml`

### `{{DEP1}}`

First named dependency, in .machine_readable/INTENT.contractile.

Appears in:

- `deno/.machine_readable/INTENT.contractile`
- `ex/.machine_readable/INTENT.contractile`
- `gleam/.machine_readable/INTENT.contractile`
- `haskell/.machine_readable/INTENT.contractile`
- `rs/.machine_readable/INTENT.contractile`
- `showcase/.machine_readable/INTENT.contractile`

### `{{DEP2}}`

Second named dependency, in .machine_readable/INTENT.contractile.

Appears in:

- `deno/.machine_readable/INTENT.contractile`
- `ex/.machine_readable/INTENT.contractile`
- `gleam/.machine_readable/INTENT.contractile`
- `haskell/.machine_readable/INTENT.contractile`
- `rs/.machine_readable/INTENT.contractile`
- `showcase/.machine_readable/INTENT.contractile`

### `{{DOMAIN}}`

Appears in:

- `deno/.machine_readable/contractiles/trust/Trustfille.a2ml`
- `validate-action/.machine_readable/contractiles/trust/Trustfile.a2ml`

### `{{DS_RECORD}}`

Appears in:

- `deno/.machine_readable/contractiles/trust/Trustfille.a2ml`
- `validate-action/.machine_readable/contractiles/trust/Trustfile.a2ml`

### `{{KEY_TAG}}`

Appears in:

- `deno/.machine_readable/contractiles/trust/Trustfille.a2ml`
- `validate-action/.machine_readable/contractiles/trust/Trustfile.a2ml`

### `{{LAST_PROOF_CHECK_DATE}}`

Appears in:

- `validate-action/.machine_readable/contractiles/trust/Trustfile.a2ml`

### `{{LICENSE}}`

SPDX identifier for this repo's licence.

Appears in:

- `deno/.machine_readable/ai/PLACEHOLDERS.adoc`
- `deno/container/Containerfile`
- `deno/container/manifest.toml`
- `deno/docs/developer/ABI-FFI-README.adoc`
- `rs/.machine_readable/ai/PLACEHOLDERS.adoc`
- `rs/container/Containerfile`
- `rs/container/manifest.toml`
- `rs/docs/developer/ABI-FFI-README.adoc`

### `{{MONOREPO_OR_STANDALONE}}`

Literally 'monorepo' or 'standalone'.

Appears in:

- `deno/.machine_readable/INTENT.contractile`
- `ex/.machine_readable/INTENT.contractile`
- `gleam/.machine_readable/INTENT.contractile`
- `haskell/.machine_readable/INTENT.contractile`
- `rs/.machine_readable/INTENT.contractile`
- `showcase/.machine_readable/INTENT.contractile`

### `{{MTA_STS_ID}}`

Appears in:

- `deno/.machine_readable/contractiles/trust/Trustfille.a2ml`
- `validate-action/.machine_readable/contractiles/trust/Trustfile.a2ml`

### `{{ONE_PARAGRAPH_ANTI_PURPOSE}}`

A paragraph on what this deliberately is NOT for.

Appears in:

- `deno/.machine_readable/INTENT.contractile`
- `ex/.machine_readable/INTENT.contractile`
- `gleam/.machine_readable/INTENT.contractile`
- `haskell/.machine_readable/INTENT.contractile`
- `rs/.machine_readable/INTENT.contractile`
- `showcase/.machine_readable/INTENT.contractile`

### `{{ONE_PARAGRAPH_PURPOSE}}`

A paragraph on what this is for.

Appears in:

- `deno/.machine_readable/INTENT.contractile`
- `ex/.machine_readable/INTENT.contractile`
- `gleam/.machine_readable/INTENT.contractile`
- `haskell/.machine_readable/INTENT.contractile`
- `rs/.machine_readable/INTENT.contractile`
- `showcase/.machine_readable/INTENT.contractile`

### `{{PGP_FINGERPRINT}}`

Full fingerprint of the security-contact PGP key. NOTE: no key is published anywhere in this estate — if none is held, delete the PGP block rather than inventing one.

Appears in:

- `deno/.machine_readable/ai/PLACEHOLDERS.adoc`
- `rs/.machine_readable/ai/PLACEHOLDERS.adoc`
- `validate-action/.machine_readable/ai/PLACEHOLDERS.adoc`

### `{{PGP_KEY_URL}}`

Public URL the PGP key can be fetched from. Same caveat as PGP_FINGERPRINT.

Appears in:

- `deno/.machine_readable/ai/PLACEHOLDERS.adoc`
- `deno/.well-known/security.txt`
- `rs/.machine_readable/ai/PLACEHOLDERS.adoc`
- `rs/.well-known/security.txt`
- `validate-action/.machine_readable/ai/PLACEHOLDERS.adoc`
- `validate-action/.well-known/security.txt`

### `{{PORT}}`

Port the container service listens on.

Appears in:

- `deno/container/Containerfile`
- `deno/container/compose.toml`
- `deno/container/deploy.k9.ncl`
- `deno/container/entrypoint.sh`
- `deno/container/manifest.toml`
- `deno/container/vordr.toml`
- `haskell/container/Containerfile`
- `haskell/container/compose.toml`
- `haskell/container/deploy.k9.ncl`
- `haskell/container/entrypoint.sh`
- `haskell/container/manifest.toml`
- `haskell/container/vordr.toml`
- `rs/container/Containerfile`
- `rs/container/compose.toml`
- `rs/container/deploy.k9.ncl`
- `rs/container/entrypoint.sh`
- `rs/container/manifest.toml`
- `rs/container/vordr.toml`

### `{{PROJECT_DESCRIPTION}}`

One-line description, matching the forge description.

Appears in:

- `deno/.machine_readable/ai/PLACEHOLDERS.adoc`
- `deno/container/Containerfile`
- `deno/container/manifest.toml`
- `rs/.machine_readable/ai/PLACEHOLDERS.adoc`
- `rs/container/Containerfile`
- `rs/container/manifest.toml`

### `{{PROJECT_DOMAIN}}`

Taxonomy value for the subject domain.

Appears in:

- `deno/.machine_readable/anchors/ANCHOR.a2ml`
- `haskell/.machine_readable/anchors/ANCHOR.a2ml`
- `rs/.machine_readable/anchors/ANCHOR.a2ml`
- `validate-action/.machine_readable/descriptiles/anchors/ANCHOR.a2ml`

### `{{PROJECT_KIND}}`

Taxonomy value (library, service, tool, lab…).

Appears in:

- `deno/.machine_readable/anchors/ANCHOR.a2ml`
- `haskell/.machine_readable/anchors/ANCHOR.a2ml`
- `rs/.machine_readable/anchors/ANCHOR.a2ml`
- `validate-action/.machine_readable/descriptiles/anchors/ANCHOR.a2ml`

### `{{PROJECT_PURPOSE}}`

One line: what this exists to do.

Appears in:

- `deno/.machine_readable/ai/PLACEHOLDERS.adoc`
- `deno/.machine_readable/anchors/ANCHOR.a2ml`
- `deno/guix.scm`
- `rs/.machine_readable/ai/PLACEHOLDERS.adoc`
- `rs/.machine_readable/anchors/ANCHOR.a2ml`
- `rs/guix.scm`

### `{{PROJECT_UNIQUE_STRENGTH}}`

What this does that its alternatives do not.

Appears in:

- `deno/.machine_readable/agent_instructions/methodology.a2ml`
- `ex/.machine_readable/agent_instructions/methodology.a2ml`
- `gleam/.machine_readable/agent_instructions/methodology.a2ml`
- `rs/.machine_readable/agent_instructions/methodology.a2ml`
- `showcase/.machine_readable/agent_instructions/methodology.a2ml`
- `validate-action/.machine_readable/bot_directives/methodology.a2ml`

### `{{PROVEN_HASH}}`

Appears in:

- `validate-action/.machine_readable/contractiles/trust/Trustfile.a2ml`

### `{{REGISTRY}}`

Container registry to publish to.

Appears in:

- `deno/container/compose.toml`
- `deno/container/ct-build.sh`
- `deno/container/deploy.k9.ncl`
- `haskell/container/compose.toml`
- `haskell/container/ct-build.sh`
- `haskell/container/deploy.k9.ncl`
- `rs/container/compose.toml`
- `rs/container/ct-build.sh`
- `rs/container/deploy.k9.ncl`

### `{{REPO_SOPS_ADOPTION_STATUS}}`

Appears in:

- `validate-action/.machine_readable/contractiles/trust/Trustfile.a2ml`

### `{{RESPONSE_TIME}}`

Initial-response SLA for a security or conduct report. Promise only what a solo maintainer can actually meet.

Appears in:

- `deno/.machine_readable/ai/PLACEHOLDERS.adoc`
- `rs/.machine_readable/ai/PLACEHOLDERS.adoc`

### `{{RGTV_ENABLED_FOR_REPO}}`

Appears in:

- `validate-action/.machine_readable/contractiles/trust/Trustfile.a2ml`

### `{{SECURITY_CONTACT}}`

Appears in:

- `validate-action/.machine_readable/contractiles/trust/Trustfile.a2ml`

### `{{SECURITY_EMAIL}}`

Address for private vulnerability reports. Two competing values exist in the estate (`6759885+hyperpolymath@users.noreply.github.com` and `security@hyperpolymath.org`) — pick one deliberately.

Appears in:

- `deno/.machine_readable/ai/PLACEHOLDERS.adoc`
- `deno/.well-known/security.txt`
- `rs/.machine_readable/ai/PLACEHOLDERS.adoc`
- `rs/.well-known/security.txt`

### `{{SECURITY_TXT_EXPIRES}}`

Appears in:

- `deno/.machine_readable/contractiles/trust/Trustfille.a2ml`
- `validate-action/.machine_readable/contractiles/trust/Trustfile.a2ml`

### `{{SERVICE_NAME}}`

Container service name.

Appears in:

- `deno/container/.gatekeeper.yaml`
- `deno/container/Containerfile`
- `deno/container/compose.toml`
- `deno/container/ct-build.sh`
- `deno/container/deploy.k9.ncl`
- `deno/container/entrypoint.sh`
- `deno/container/manifest.toml`
- `deno/container/vordr.toml`
- `haskell/container/.gatekeeper.yaml`
- `haskell/container/Containerfile`
- `haskell/container/compose.toml`
- `haskell/container/ct-build.sh`
- `haskell/container/deploy.k9.ncl`
- `haskell/container/entrypoint.sh`
- `haskell/container/manifest.toml`
- `haskell/container/vordr.toml`
- `rs/container/.gatekeeper.yaml`
- `rs/container/Containerfile`
- `rs/container/compose.toml`
- `rs/container/ct-build.sh`
- `rs/container/deploy.k9.ncl`
- `rs/container/entrypoint.sh`
- `rs/container/manifest.toml`
- `rs/container/vordr.toml`

### `{{THIS_REPO}}`

Appears in:

- `validate-action/.machine_readable/contractiles/trust/Trustfile.a2ml`

### `{{VERSION}}`

Version/tag for the container image.

Appears in:

- `deno/container/deploy.k9.ncl`
- `deno/container/manifest.toml`
- `deno/container/vordr.toml`
- `haskell/container/deploy.k9.ncl`
- `haskell/container/manifest.toml`
- `haskell/container/vordr.toml`
- `rs/container/deploy.k9.ncl`
- `rs/container/manifest.toml`
- `rs/container/vordr.toml`

### `{{WEBSITE}}`

Project homepage URL, or delete the field if there is none.

Appears in:

- `deno/.machine_readable/ai/PLACEHOLDERS.adoc`
- `deno/.well-known/security.txt`
- `rs/.machine_readable/ai/PLACEHOLDERS.adoc`
- `rs/.well-known/security.txt`

---

Generated by the estate top-up pass. Rationale and the governing rulings are
in `hyperpolymath/standards`; the token vocabulary is
`.machine_readable/ai/PLACEHOLDERS.adoc` in `rsr-template-repo`.
