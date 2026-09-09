#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

failures=0

fail() {
  printf 'membership error: %s\n' "$1" >&2
  failures=$((failures + 1))
}

check_member() {
  local group="$1"
  local name="$2"
  local path="$3"

  if ! grep -Fq "(member \"${name}\" (group \"${group}\") (path \"${path}\")" .machine_readable/6a2/ECOSYSTEM.a2ml; then
    fail ".machine_readable/6a2/ECOSYSTEM.a2ml missing ${group}/${name} at ${path}"
  fi

  if [[ ! -d "${path}" ]]; then
    fail "${group}/${name} vendored directory '${path}' is missing"
    return
  fi

  if ! git ls-files "${path}/" | grep -q .; then
    fail "${group}/${name} vendored directory '${path}' has no tracked files"
  fi
}

check_member implementations a2ml-rs rs
check_member implementations a2ml_ex ex
check_member implementations a2ml_gleam gleam
check_member implementations a2ml-deno deno
check_member implementations a2ml-haskell haskell
check_member tooling vscode-a2ml members/tooling/vscode-a2ml
check_member ci a2ml-validate-action validate-action
check_member examples a2ml-showcase showcase

# Members were consolidated into this monorepo by aa4b836. A surviving gitlink
# without a matching .gitmodules entry breaks actions/checkout cleanup and can
# never be initialized, so fail with the exact stale paths if one reappears.
while IFS= read -r gitlink; do
  [[ -n "${gitlink}" ]] && fail "orphan submodule gitlink remains at ${gitlink}"
done < <(git ls-files -s | awk '$1 == "160000" { print $4 }')

if grep -R "contractiles-a2-lab" members >/dev/null 2>&1; then
  fail "contractiles-a2-lab must not be a member submodule"
fi

if ! grep -Fq '(related "contractiles-a2-lab"' .machine_readable/6a2/ECOSYSTEM.a2ml; then
  fail ".machine_readable/6a2/ECOSYSTEM.a2ml missing private contractiles-a2-lab related reference"
fi

if [[ "${failures}" -gt 0 ]]; then
  exit 1
fi

printf 'membership integrity passed\n'
