# Setup

This repository is a coordination hub and satellite of
`hyperpolymath/standards`.

## Fresh Checkout

```sh
git clone https://github.com/hyperpolymath/a2ml-ecosystem.git
cd a2ml-ecosystem
git submodule update --init --recursive
```

For local estate work, prefer:

```sh
scripts/init-submodules.sh
scripts/check-membership.sh
```

`scripts/init-submodules.sh` initializes from sibling local checkouts when
they are present and skips members that are not available in the local scope.

## Validation

```sh
INPUT_PATH=. INPUT_STRICT=true INPUT_PATHS_IGNORE=$'conformance/\nmembers/' ../a2ml/a2ml-validate-action/validate-a2ml.sh
INPUT_PATH=conformance/valid INPUT_STRICT=true ../a2ml/a2ml-validate-action/validate-a2ml.sh
INPUT_PATH=conformance/invalid INPUT_STRICT=true ../a2ml/a2ml-validate-action/validate-a2ml.sh
```

The invalid conformance command is expected to fail.
