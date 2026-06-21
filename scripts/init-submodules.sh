#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
workspace_root="$(cd "${repo_root}/.." && pwd)"

init_member() {
  local group="$1"
  local name="$2"
  local local_rel="$3"
  local dest="${repo_root}/members/${group}/${name}"
  local source="${workspace_root}/${local_rel}"
  local gitlink

  gitlink="$(git -C "${repo_root}" rev-parse ":members/${group}/${name}" 2>/dev/null || true)"
  if [[ -z "${gitlink}" ]]; then
    printf 'skip %s/%s: no gitlink recorded\n' "${group}" "${name}"
    return 0
  fi

  if [[ -e "${dest}/.git" || -f "${dest}/.git" ]]; then
    printf 'present %s/%s\n' "${group}" "${name}"
    return 0
  fi

  if [[ ! -d "${source}/.git" ]]; then
    printf 'skip %s/%s: local repo not in scope at %s\n' "${group}" "${name}" "${source}"
    return 0
  fi

  mkdir -p "$(dirname "${dest}")"
  git -c protocol.file.allow=always clone "${source}" "${dest}"
  git -C "${dest}" checkout --detach "${gitlink}"
  git -C "${repo_root}" submodule absorbgitdirs "members/${group}/${name}" >/dev/null 2>&1 || true
  printf 'initialized %s/%s at %s\n' "${group}" "${name}" "${gitlink}"
}

init_member implementations a2ml-rs "a2ml/a2ml-core/a2ml-rs"
init_member implementations a2ml_ex "a2ml/a2ml_ex"
init_member implementations a2ml_gleam "a2ml/a2ml_gleam"
init_member implementations a2ml-deno "a2ml/a2ml-core/a2ml-deno"
init_member implementations a2ml-haskell "a2ml/a2ml-core/a2ml-haskell"
init_member tooling tree-sitter-a2ml "a2ml/tree-sitter-a2ml"
init_member tooling vscode-a2ml "a2ml/vscode-a2ml"
init_member tooling pandoc-a2ml "a2ml/pandoc-a2ml"
init_member tooling a2mliser "isers/a2mliser"
init_member ci a2ml-validate-action "a2ml/a2ml-validate-action"
init_member ci a2ml-pre-commit "a2ml/a2ml-core/a2ml-pre-commit"
init_member examples a2ml-showcase "a2ml/a2ml-core/a2ml-showcase"
