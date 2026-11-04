#!/usr/bin/env bash
set -uo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
root="$(mktemp -d)"
failures=0
checks=0

trap 'rm -rf "$root"' EXIT

export HOME="$root/home"
mkdir -p "$HOME/.local/bin"

pass() { checks=$((checks + 1)); }
fail() { checks=$((checks + 1)); failures=$((failures + 1)); echo "FAIL: $*"; }

assert_contains() {
  local description="$1" haystack="$2" needle="$3"
  if [[ "$haystack" == *"$needle"* ]]; then pass; else fail "$description (missing: $needle)"; fi
}

assert_not_contains() {
  local description="$1" haystack="$2" needle="$3"
  if [[ "$haystack" != *"$needle"* ]]; then pass; else fail "$description (unexpected: $needle)"; fi
}

assert_equals() {
  local description="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then pass; else fail "$description (expected: $expected, got: $actual)"; fi
}

# shellcheck source=../dev-env.sh
source "$project_root/dev-env.sh"
set +e

test_zshrc_block() {
  : >"$HOME/.zshrc"
  write_zshrc_block >/dev/null
  write_zshrc_block >/dev/null
  local content
  content="$(cat "$HOME/.zshrc")"

  assert_equals "zshrc block is written once" 1 "$(grep -c '# >>> dev-env >>>' "$HOME/.zshrc")"
  assert_contains "zshrc activates mise" "$content" 'mise activate zsh'
  assert_contains "zshrc hooks direnv" "$content" 'direnv hook zsh'
  assert_contains "zshrc loads cargo" "$content" '.cargo/env'
}

test_gitconfig_filter() {
  local filtered
  filtered="$(printf '%s\n' \
    'user.name=Federico' \
    'core.pager=delta' \
    'interactive.difffilter=delta --color-only' \
    'delta.navigate=true' \
    'merge.conflictstyle=zdiff3' \
    'credential.helper=store' \
    'user.signingkey=ABCDEF' \
    'url.git@github.com:.insteadof=https://github.com/' | filter_gitconfig)"

  assert_contains "filter keeps the user name" "$filtered" 'user.name=Federico'
  assert_contains "filter keeps the pager" "$filtered" 'core.pager=delta'
  assert_contains "filter keeps the diff filter" "$filtered" 'interactive.difffilter=delta --color-only'
  assert_contains "filter keeps delta options" "$filtered" 'delta.navigate=true'
  assert_contains "filter keeps the conflict style" "$filtered" 'merge.conflictstyle=zdiff3'
  assert_not_contains "filter drops credential helpers" "$filtered" 'credential.helper'
  assert_not_contains "filter drops signing keys" "$filtered" 'signingkey'
  assert_not_contains "filter drops url rewrites" "$filtered" 'insteadof'
}

test_gitconfig_replay_without_delta() {
  local previous_here="$HERE" previous_path="$PATH"
  HERE="$root/archive"
  mkdir -p "$HERE"
  printf '%s\n' 'user.name=Federico' 'core.pager=delta' 'delta.navigate=true' >"$HERE/gitconfig.txt"
  export GIT_CONFIG_GLOBAL="$root/gitconfig-without-delta"
  : >"$GIT_CONFIG_GLOBAL"
  PATH="/usr/bin:/bin"

  replay_gitconfig >/dev/null 2>&1

  PATH="$previous_path"
  HERE="$previous_here"
  assert_equals "replay sets the user name" Federico "$(git config --global user.name)"
  assert_equals "replay skips the pager when delta is missing" "" "$(git config --global core.pager)"
  assert_equals "replay still sets delta options" true "$(git config --global delta.navigate)"
  unset GIT_CONFIG_GLOBAL
}

test_gitconfig_replay_with_delta() {
  local previous_here="$HERE" previous_path="$PATH"
  HERE="$root/archive"
  mkdir -p "$HERE" "$root/fakedelta"
  printf '#!/bin/sh\n' >"$root/fakedelta/delta"
  chmod +x "$root/fakedelta/delta"
  printf '%s\n' 'core.pager=delta' 'interactive.difffilter=delta --color-only' >"$HERE/gitconfig.txt"
  export GIT_CONFIG_GLOBAL="$root/gitconfig-with-delta"
  : >"$GIT_CONFIG_GLOBAL"
  PATH="$root/fakedelta:$PATH"

  replay_gitconfig >/dev/null 2>&1

  PATH="$previous_path"
  HERE="$previous_here"
  assert_equals "replay sets the pager when delta exists" delta "$(git config --global core.pager)"
  assert_equals "replay keeps values containing spaces" "delta --color-only" "$(git config --global interactive.difffilter)"
  unset GIT_CONFIG_GLOBAL
}

test_zshrc_block
test_gitconfig_filter
test_gitconfig_replay_without_delta
test_gitconfig_replay_with_delta

echo "$checks checks, $failures failed"
[ "$failures" -eq 0 ]
