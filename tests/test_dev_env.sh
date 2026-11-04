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

test_zshrc_block

echo "$checks checks, $failures failed"
[ "$failures" -eq 0 ]
