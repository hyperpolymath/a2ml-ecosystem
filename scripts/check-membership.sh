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
  local url="https://github.com/hyperpolymath/${name}.git"
  local path="members/${group}/${name}"
  local module="submodule.${path}"
  local actual_url
  local actual_branch
  local mode

  if ! grep -Fq "(member \"${name}\" (group \"${group}\")" .machine_readable/6a2/ECOSYSTEM.a2ml; then
    fail ".machine_readable/6a2/ECOSYSTEM.a2ml missing ${group}/${name}"
  fi

  actual_url="$(git config -f .gitmodules --get "${module}.url" || true)"
  if [[ "${actual_url}" != "${url}" ]]; then
    fail ".gitmodules ${path} url is '${actual_url}', expected '${url}'"
  fi

  actual_branch="$(git config -f .gitmodules --get "${module}.branch" || true)"
  if [[ "${actual_branch}" != "main" ]]; then
    fail ".gitmodules ${path} branch is '${actual_branch}', expected 'main'"
  fi

  mode="$(git ls-files -s "${path}" | awk '{print $1}')"
  if [[ "${mode}" != "160000" ]]; then
    fail "${path} is not a pinned submodule gitlink"
  fi
}

check_member implementations a2ml-rs
check_member implementations a2ml_ex
check_member implementations a2ml_gleam
check_member implementations a2ml-deno
check_member implementations a2ml-haskell
check_member tooling tree-sitter-a2ml
check_member tooling vscode-a2ml
check_member tooling pandoc-a2ml
check_member tooling a2mliser
check_member ci a2ml-validate-action
check_member ci a2ml-pre-commit
check_member examples a2ml-showcase

if grep -R "contractiles-a2-lab" .gitmodules members >/dev/null 2>&1; then
  fail "contractiles-a2-lab must not be a member submodule"
fi

if ! grep -Fq '(related "contractiles-a2-lab"' .machine_readable/6a2/ECOSYSTEM.a2ml; then
  fail ".machine_readable/6a2/ECOSYSTEM.a2ml missing private contractiles-a2-lab related reference"
fi

if [[ "${failures}" -gt 0 ]]; then
  exit 1
fi

printf 'membership integrity passed\n'
