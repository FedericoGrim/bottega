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

assert_true() {
  local description="$1" condition="$2"
  if [ "$condition" = 1 ]; then pass; else fail "$description"; fi
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

test_export_archive() {
  mkdir -p "$HOME/.config/mise"
  printf '[tools]\nbat = "latest"\n' >"$HOME/.config/mise/config.toml"
  export GIT_CONFIG_GLOBAL="$root/gitconfig-export"
  git config --global user.name Federico
  git config --global credential.helper store

  export_env >/dev/null 2>&1

  local archive listing manifest gitconfig
  archive="$(find "$HOME" -maxdepth 1 -name 'dev-env-*.tar.gz' | head -n1)"
  listing="$(tar -tzf "$archive" 2>/dev/null)"
  manifest="$(tar -xzOf "$archive" dev-env/manifest.txt 2>/dev/null)"
  gitconfig="$(tar -xzOf "$archive" dev-env/gitconfig.txt 2>/dev/null)"

  assert_contains "archive includes the mise config" "$listing" 'dev-env/files/.config/mise/config.toml'
  for tool in uv mise pnpm rustc cargo java dotnet bat eza delta direnv; do
    assert_contains "manifest lists $tool" "$manifest" "$tool"
  done
  assert_contains "archive keeps the git user name" "$gitconfig" 'user.name=Federico'
  assert_not_contains "archive drops credential helpers" "$gitconfig" 'credential'
  rm -f "$archive"
  unset GIT_CONFIG_GLOBAL
}

# shellcheck disable=SC2016
setup_fakes() {
  fakebin="$root/fakebin"
  calls="$root/calls.log"
  rm -rf "$fakebin" "$calls"
  mkdir -p "$fakebin"
  : >"$calls"
  export CALLS="$calls"
  export DOTNET_CANDIDATE="10.0.114"
  printf '#!/bin/bash\nexec "$@"\n' >"$fakebin/sudo"
  printf '#!/bin/bash\necho "apt-get $*" >>"$CALLS"\n' >"$fakebin/apt-get"
  printf '#!/bin/bash\necho "Candidate: $DOTNET_CANDIDATE"\n' >"$fakebin/apt-cache"
  printf '#!/bin/bash\necho "mise $*" >>"$CALLS"\n' >"$fakebin/mise"
  cat >"$fakebin/curl" <<'FAKE'
#!/bin/bash
case "$*" in
  *sh.rustup.rs*) printf '#!/bin/sh\necho "rustup $*" >>"$CALLS"\n' ;;
esac
FAKE
  chmod +x "$fakebin"/*
  cp "$fakebin/mise" "$HOME/.local/bin/mise"
  rm -rf "$HOME/.cargo" "$HOME/.config/mise"
  PATH="$fakebin:/usr/bin:/bin"
}

calls_log() { cat "$calls"; }

test_cli_tools_with_exported_config() {
  setup_fakes
  mkdir -p "$HOME/.config/mise"
  : >"$HOME/.config/mise/config.toml"

  install_cli_tools >/dev/null 2>&1

  assert_contains "cli tools install what the config lists" "$(calls_log)" 'mise install'
  assert_contains "cli tools make sure the five tools are in the config" "$(calls_log)" 'mise use -g bat eza delta direnv uv'
}

test_cli_tools_without_config() {
  setup_fakes

  install_cli_tools >/dev/null 2>&1

  assert_not_contains "cli tools skip install without a config" "$(calls_log)" 'mise install'
  assert_contains "cli tools still install the five tools" "$(calls_log)" 'mise use -g bat eza delta direnv uv'
}

test_languages() {
  setup_fakes

  install_languages >/dev/null 2>&1

  assert_contains "languages install the JDK and Maven" "$(calls_log)" 'apt-get install -y openjdk-21-jdk maven python3'
  assert_contains "languages install the dotnet sdk" "$(calls_log)" 'apt-get install -y dotnet-sdk-10.0'
  assert_contains "languages install Go and Node with mise" "$(calls_log)" 'mise use -g go@latest node@lts'
  assert_contains "languages install rust non-interactively" "$(calls_log)" 'rustup -y --profile default -c rust-analyzer'
  assert_contains "languages enable pnpm through corepack" "$(calls_log)" 'mise exec node@lts -- corepack enable --install-directory'
}

test_languages_without_dotnet_package() {
  setup_fakes
  export DOTNET_CANDIDATE="(none)"

  local output
  output="$(install_languages 2>&1)"

  assert_not_contains "no dotnet install when the package is missing" "$(calls_log)" 'dotnet-sdk-10.0'
  assert_contains "a missing dotnet package is reported" "$output" 'dotnet-sdk-10.0'
}

test_languages_skip_rust_when_present() {
  setup_fakes
  mkdir -p "$HOME/.cargo/bin"
  : >"$HOME/.cargo/bin/rustup"
  chmod +x "$HOME/.cargo/bin/rustup"

  install_languages >/dev/null 2>&1

  assert_not_contains "rust is not installed twice" "$(calls_log)" 'rustup -y'
}

stub_install_steps() {
  local step
  for step in install_packages install_neovim install_treesitter install_lazygit install_claude \
    install_font install_ohmyzsh apply_files write_zshrc_block replay_gitconfig install_containers \
    install_flutter install_completions install_cli_tools install_languages final_notes; do
    eval "$step() { echo $step >>\"\$CALLS\"; }"
  done
  sync_nvim() { echo "sync_nvim PATH=$PATH" >>"$CALLS"; }
}

position_of() { calls_log | grep -n "^$1" | head -n1 | cut -d: -f1; }

test_install_runs_languages_only_on_request() {
  setup_fakes

  (stub_install_steps; install_env) >/dev/null 2>&1
  assert_not_contains "languages are opt-in" "$(calls_log)" 'install_languages'

  : >"$calls"
  (stub_install_steps; install_env --languages) >/dev/null 2>&1
  assert_contains "--languages installs the toolchains" "$(calls_log)" 'install_languages'
}

test_install_order() {
  setup_fakes

  (stub_install_steps; install_env --languages) >/dev/null 2>&1

  local files cli git_replay languages sync
  files="$(position_of apply_files)"
  cli="$(position_of install_cli_tools)"
  git_replay="$(position_of replay_gitconfig)"
  languages="$(position_of install_languages)"
  sync="$(position_of sync_nvim)"

  assert_true "config files come before the CLI tools" "$((files < cli))"
  assert_true "delta is installed before git settings are replayed" "$((cli < git_replay))"
  assert_true "toolchains come before the plugin and server install" "$((languages < sync))"
  assert_contains "mise shims are on the PATH for Mason" "$(calls_log)" '.local/share/mise/shims'
  assert_contains "cargo is on the PATH for Mason" "$(calls_log)" '.cargo/bin'
}

test_unknown_option_is_rejected() {
  setup_fakes

  if (stub_install_steps; install_env --bogus) >/dev/null 2>&1; then
    fail "an unknown option must fail"
  else
    pass
  fi
}

test_usage_mentions_languages() {
  assert_contains "usage documents --languages" "$(usage)" '--languages'
}

# shellcheck disable=SC2016
setup_fake_nvim() {
  setup_fakes
  printf '#!/bin/bash\necho "nvim $*" >>"$CALLS"\nwhile [ $# -gt 0 ]; do\n  case "$1" in luafile) ;; -c) shift; case "$1" in "luafile "*) cp "${1#luafile }" "$CALLS.lua" ;; esac ;; esac\n  shift\ndone\n' >"$fakebin/nvim"
  chmod +x "$fakebin/nvim"
  NVIM_BIN="$fakebin/nvim"
}

test_sync_nvim_installs_plugins_then_tools() {
  setup_fake_nvim

  sync_nvim >/dev/null 2>&1

  local lua
  lua="$(cat "$calls.lua" 2>/dev/null)"
  assert_contains "plugins are synced first" "$(calls_log)" 'nvim --headless +Lazy! sync +qa'
  assert_contains "a lua script is run to install the tools" "$(calls_log)" 'luafile'
  assert_contains "script installs treesitter parsers and waits" "$lua" 'require("nvim-treesitter").install'
  assert_contains "script waits for the parsers" "$lua" ':wait('
  for name in c_sharp go java rust python tsx; do
    assert_contains "script installs the $name parser" "$lua" "\"$name\""
  done
  for name in pyright ruff jdtls gopls rust-analyzer vtsls csharpier netcoredbg yaml-language-server debugpy; do
    assert_contains "script installs $name with mason" "$lua" "\"$name\""
  done
  assert_contains "script falls back to a pinned roslyn" "$lua" "$ROSLYN_FALLBACK_VERSION"
  assert_contains "the pinned roslyn is a real version" "$ROSLYN_FALLBACK_VERSION" '5.'
}

test_sync_nvim_without_nvim_is_not_an_error() {
  setup_fakes
  NVIM_BIN="$root/does-not-exist"

  assert_equals "sync is skipped silently without nvim" 0 "$(sync_nvim >/dev/null 2>&1; echo $?)"
}

test_export_keeps_only_mise_tools() {
  mkdir -p "$HOME/.config/mise"
  printf '[env]\nGITHUB_TOKEN = "ghp_secret"\n\n[tools]\nbat = "latest"\neza = "latest"\n\n[settings]\nexperimental = true\n' >"$HOME/.config/mise/config.toml"
  export GIT_CONFIG_GLOBAL="$root/gitconfig-mise"
  : >"$GIT_CONFIG_GLOBAL"

  export_env >/dev/null 2>&1

  local archive exported
  archive="$(find "$HOME" -maxdepth 1 -name 'dev-env-*.tar.gz' | head -n1)"
  exported="$(tar -xzOf "$archive" dev-env/files/.config/mise/config.toml 2>/dev/null)"

  assert_contains "exported mise config keeps the tools section" "$exported" '[tools]'
  assert_contains "exported mise config keeps the tools" "$exported" 'eza = "latest"'
  assert_not_contains "exported mise config drops the env section" "$exported" 'GITHUB_TOKEN'
  assert_not_contains "exported mise config drops the secret value" "$exported" 'ghp_secret'
  assert_not_contains "exported mise config drops other sections" "$exported" 'experimental'
  rm -f "$archive"
  unset GIT_CONFIG_GLOBAL
}

test_zshrc_block
test_gitconfig_filter
test_gitconfig_replay_without_delta
test_gitconfig_replay_with_delta
test_export_archive
test_export_keeps_only_mise_tools
test_cli_tools_with_exported_config
test_cli_tools_without_config
test_languages
test_languages_without_dotnet_package
test_languages_skip_rust_when_present
test_install_runs_languages_only_on_request
test_install_order
test_unknown_option_is_rejected
test_usage_mentions_languages
test_sync_nvim_installs_plugins_then_tools
test_sync_nvim_without_nvim_is_not_an_error

echo "$checks checks, $failures failed"
[ "$failures" -eq 0 ]
