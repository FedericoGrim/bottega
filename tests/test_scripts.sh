#!/usr/bin/env bash
set -uo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
real_tmux="$(command -v tmux)"
root="$(mktemp -d)"
failures=0
checks=0

export HOME="$root/home"
export TMUX_TMPDIR="$root/tmux"
export TERM="xterm-256color"
unset TMUX TMUX_PANE DEV_DIR DEV_PERSONAL_DIR
mkdir -p "$HOME/.local/bin" "$HOME/.cache" "$TMUX_TMPDIR" "$root/fakebin" "$root/work"

fakebin="$root/fakebin"
export PATH="$fakebin:$HOME/.local/bin:$PATH"

pass() { checks=$((checks + 1)); }
fail() { checks=$((checks + 1)); failures=$((failures + 1)); echo "FAIL: $*"; }

assert_true() {
  local description="$1"
  shift
  if "$@"; then pass; else fail "$description"; fi
}

assert_contains() {
  local description="$1" haystack="$2" needle="$3"
  if [[ "$haystack" == *"$needle"* ]]; then pass; else fail "$description (missing: $needle)"; fi
}

assert_not_contains() {
  local description="$1" haystack="$2" needle="$3"
  if [[ "$haystack" != *"$needle"* ]]; then pass; else fail "$description (unexpected: $needle)"; fi
}

wait_for() {
  local seconds="$1"
  shift
  local deadline=$((SECONDS + seconds))
  while [ "$SECONDS" -lt "$deadline" ]; do
    if "$@"; then return 0; fi
    sleep 0.3
  done
  return 1
}

write_fake_marker() {
  printf '#!/bin/bash\necho "FAKE-%s $*"\nsleep 120\n' "$1" >"$fakebin/$1"
  chmod +x "$fakebin/$1"
}

write_fakes() {
  printf '#!/bin/bash\nexec bash "$@"\n' >"$fakebin/zsh"
  chmod +x "$fakebin/zsh"
  for name in nvim claude opencode lazygit podman-tui lazydocker; do write_fake_marker "$name"; done

  cat >"$fakebin/podman" <<'EOF'
#!/bin/bash
echo "podman $*" >>"$FAKE_LOG_DIR/podman.log"
case "$1" in
  inspect) echo "${FAKE_PODMAN_RUNNING:-true}" ;;
  exec) echo "FAKE-PODMAN-EXEC $*"; if [ -t 1 ]; then sleep 120; fi ;;
esac
EOF

  sed 's/podman/docker/g; s/PODMAN/DOCKER/g' "$fakebin/podman" >"$fakebin/fake-docker"
  printf '#!/bin/bash\necho "FAKE-SHELL $*"\n' >"$fakebin/fake-shell"

  cat >"$fakebin/devcontainer" <<'EOF'
#!/bin/bash
echo "devcontainer $*" >>"$FAKE_LOG_DIR/devcontainer.log"
workspace=""
while [ $# -gt 0 ]; do
  [ "$1" = "--workspace-folder" ] && workspace="$2"
  shift
done
echo "log line on stderr" >&2
echo "{\"outcome\":\"success\",\"containerId\":\"abc123\",\"remoteUser\":\"vscode\",\"remoteWorkspaceFolder\":\"/workspaces/$(basename "$workspace")\"}"
EOF

  cat >"$fakebin/tmux" <<EOF
#!/bin/bash
for argument in "\$@"; do
  case "\$argument" in attach | attach-session | switch-client) exit 0 ;; esac
done
exec "$real_tmux" "\$@"
EOF
  chmod +x "$fakebin/podman" "$fakebin/fake-docker" "$fakebin/fake-shell" "$fakebin/devcontainer" "$fakebin/tmux"
}

export FAKE_LOG_DIR="$root/logs"
mkdir -p "$FAKE_LOG_DIR"
write_fakes

# shellcheck disable=SC2016
printf 'export PATH="%s:%s/.local/bin:$PATH"\n' "$fakebin" "$HOME" >"$HOME/.bash_profile"
printf 'set -g mouse on\n' >"$HOME/.tmux-terminals.conf"
printf 'set -g status-position top\n' >"$HOME/.tmux-side.conf"
printf 'old dev\n' >"$HOME/.local/bin/dev"
printf 'old wrapper\n' >"$HOME/.local/bin/dev-container"
printf 'old wrapper\n' >"$HOME/.local/bin/dev-opencode"

echo "== install.sh"
"$project_root/install.sh" >/dev/null 2>&1
"$project_root/install.sh" >/dev/null 2>&1
for script in dev dev-in dev-up dev-guard dev-o dev-c-c dev-c-o dev-stop dev-side dev-side-width dctl dev-personal-setup; do
  assert_true "$script is installed and executable" test -x "$HOME/.local/bin/$script"
done
for old_name in dev-container dev-opencode; do
  assert_true "old $old_name is removed" test ! -e "$HOME/.local/bin/$old_name"
done
assert_true "removed wrappers are backed up" bash -c "grep -rlq 'old wrapper' $HOME/.dev-variants-backup-*"
assert_true "replaced dev was backed up" bash -c "grep -rq 'old dev' $HOME/.dev-variants-backup-*"
assert_true "terminals block is added once" test "$(grep -c '>>> dev-variants >>>' "$HOME/.tmux-terminals.conf")" = 1
assert_contains "terminals keeps existing settings" "$(cat "$HOME/.tmux-terminals.conf")" "set -g mouse on"
assert_true "missing tmux.conf is installed" test -f "$HOME/.tmux.conf"
assert_contains "existing tmux-side.conf is kept" "$(cat "$HOME/.tmux-side.conf")" "set -g status-position top"
assert_true "existing tmux-side.conf is not overwritten" test "$(wc -l <"$HOME/.tmux-side.conf")" = 1

echo "== dev-personal-setup"
mkdir -p "$root/nvimroot/bin" "$root/nvimroot/share/nvim/runtime" "$root/tools"
printf '#!/bin/bash\necho nvim\n' >"$root/nvimroot/bin/nvim"
chmod +x "$root/nvimroot/bin/nvim"
ln -s "$root/nvimroot/bin/nvim" "$root/tools/nvim"
mkdir -p "$HOME/.config/nvim" "$HOME/.claude/skills/demo"
echo 'return {}' >"$HOME/.config/nvim/init.lua"
echo '# rules' >"$HOME/.claude/CLAUDE.md"
echo 'skill' >"$HOME/.claude/skills/demo/SKILL.md"
echo 'SECRET-TOKEN' >"$HOME/.claude/.credentials.json"
PATH="$root/tools:$PATH" dev-personal-setup >/dev/null 2>&1
personal="$HOME/.local/share/dev-personal"
assert_true "neovim runtime copied" test -x "$personal/nvim/bin/nvim"
assert_true "neovim config copied" test -f "$personal/config/nvim/init.lua"
assert_true "claude binary copied" test -x "$personal/bin/claude"
assert_true "claude rules copied" test -f "$personal/claude/CLAUDE.md"
assert_true "claude skills copied" test -f "$personal/claude/skills/demo/SKILL.md"
assert_true "credentials are not copied" test ! -e "$personal/claude/.credentials.json"
assert_true "no secret anywhere in the personal dir" bash -c "! grep -rq SECRET-TOKEN '$personal'"

echo "== dev-up"
mkdir -p "$root/work/my.proj/src"
dev-up "$root/work/my.proj" >/dev/null 2>&1
config="$root/work/my.proj/.devcontainer/devcontainer.json"
assert_true "default config is generated" test -f "$config"
assert_contains "default config uses keep-id" "$(cat "$config")" "keep-id"
state="$HOME/.cache/dev/my_proj.json"
assert_true "state file written" test -f "$state"
assert_contains "state has container id" "$(jq -r .containerId "$state")" "abc123"
assert_contains "state has local root" "$(jq -r .localWorkspaceFolder "$state")" "$root/work/my.proj"
log="$(cat "$FAKE_LOG_DIR/devcontainer.log")"
assert_contains "up uses podman" "$log" "up --docker-path podman"
assert_contains "personal dir is mounted" "$log" "--mount type=bind,source=$personal,target=/opt/personal"
echo '{"name":"custom"}' >"$config"
dev-up "$root/work/my.proj" >/dev/null 2>&1
assert_contains "existing config is untouched" "$(cat "$config")" '"custom"'

echo "== dev-in"
mkdir -p "$root/work/plain"
assert_contains "runs on the host without a container" "$(cd "$root/work/plain" && dev-in echo hello)" "hello"
(cd "$root/work/my.proj/src" && dev-in make test >/dev/null 2>&1)
exec_line="$(grep 'podman exec' "$FAKE_LOG_DIR/podman.log" | tail -n 1)"
assert_contains "exec has no tty flag when not interactive" "$exec_line" "exec -i -u vscode"
assert_contains "workdir follows the host subdirectory" "$exec_line" "-w /workspaces/my.proj/src"
assert_contains "claude config dir is set" "$exec_line" "CLAUDE_CONFIG_DIR=/opt/personal/claude"
assert_contains "container id is used" "$exec_line" "abc123"
message="$(cd "$root/work/my.proj" && FAKE_PODMAN_RUNNING=false dev-in ls 2>&1)"
assert_contains "stopped container is reported" "$message" "not running"

echo "== dev (options)"
assert_contains "unknown agent is rejected" "$(cd "$root/work/plain" && dev --agent foo 2>&1)" "unknown agent"
help_text="$(dev --help)"
for command_name in dev-o dev-c-c dev-c-o dev-in dev-stop dev-personal-setup; do
  assert_contains "help lists $command_name" "$help_text" "$command_name"
done
assert_contains "unknown option is rejected" "$(cd "$root/work/plain" && dev --nope 2>&1)" "unknown option"

side_windows() { "$real_tmux" -L side list-windows -t "=$1" -F '#{window_name}' 2>/dev/null | tr '\n' ' '; }
side_ready() { [ "$(side_windows "$1")" = "$2 lazygit ${3:-podman} " ]; }
pane_text() {
  local socket_args=()
  if [ "$1" = "-L" ]; then
    socket_args=(-L "$2")
    shift 2
  fi
  "$real_tmux" "${socket_args[@]}" capture-pane -p -J "$@"
}

echo "== dev-o (host project)"
mkdir -p "$root/work/hostproj"
(cd "$root/work/hostproj" && dev-o >/dev/null 2>&1)
assert_true "main session exists" "$real_tmux" has-session -t "=hostproj"
assert_true "main window has 3 panes" test "$("$real_tmux" list-panes -t hostproj:code | wc -l)" = 3
assert_true "side tabs are opencode, lazygit, podman" wait_for 15 side_ready hostproj opencode
assert_true "terminals session exists" wait_for 10 "$real_tmux" -L terminals has-session -t "=hostproj"
sleep 1
assert_contains "editor runs nvim" "$(pane_text -t hostproj:code.{top-left})" "FAKE-nvim"
assert_contains "agent tab runs opencode" "$(pane_text -L side -t hostproj:opencode)" "FAKE-opencode"
assert_contains "lazygit tab runs lazygit" "$(pane_text -L side -t hostproj:lazygit)" "FAKE-lazygit"
assert_contains "podman tab runs podman-tui" "$(pane_text -L side -t hostproj:podman)" "FAKE-podman-tui"
assert_true "no guard is installed for host projects" test ! -e "$root/work/hostproj/.claude/settings.local.json"

echo "== dev-c-c (agent on the host)"
mkdir -p "$root/work/ctr"
(cd "$root/work/ctr" && dev-c-c >/dev/null 2>&1)
assert_true "container config is generated" test -f "$root/work/ctr/.devcontainer/devcontainer.json"
assert_true "claude tab exists" wait_for 15 side_ready ctr claude
sleep 1
assert_contains "editor runs inside the container" "$(pane_text -t ctr:code.{top-left})" "FAKE-PODMAN-EXEC"
assert_contains "editor command is nvim" "$(pane_text -t ctr:code.{top-left})" "nvim"
assert_contains "agent runs on the host" "$(pane_text -L side -t ctr:claude)" "FAKE-claude"
guard_settings="$(cat "$root/work/ctr/.claude/settings.local.json" 2>/dev/null)"
assert_contains "guard hook is installed" "$guard_settings" "dev-guard"
assert_contains "dev-in is pre-approved" "$guard_settings" "Bash(dev-in:*)"
assert_true "terminals first tab is a container shell" wait_for 10 bash -c "'$real_tmux' -L terminals capture-pane -p -J -S - -t ctr | grep -q FAKE-PODMAN-EXEC"

echo "== dev-c-o"
mkdir -p "$root/work/ctr3"
(cd "$root/work/ctr3" && dev-c-o >/dev/null 2>&1)
assert_true "dev-c-o opens an opencode tab" wait_for 15 side_ready ctr3 opencode
sleep 1
assert_contains "dev-c-o editor runs in the container" "$(pane_text -t ctr3:code.{top-left})" "FAKE-PODMAN-EXEC"
assert_contains "dev-c-o agent runs on the host" "$(pane_text -L side -t ctr3:opencode)" "FAKE-opencode"

echo "== dev-c-o --agent-in-container"
mkdir -p "$root/work/ctr2"
(cd "$root/work/ctr2" && dev-c-o --agent-in-container >/dev/null 2>&1)
assert_true "opencode tab exists" wait_for 15 side_ready ctr2 opencode
sleep 1
agent_text="$(pane_text -L side -t ctr2:opencode)"
assert_contains "agent runs through dev-in" "$agent_text" "FAKE-PODMAN-EXEC"
assert_contains "agent is opencode" "$agent_text" "opencode"
assert_true "no guard when the agent is in the container" test ! -e "$root/work/ctr2/.claude/settings.local.json"

echo "== dev-side-width"
"$real_tmux" new-session -d -s widthtest -x 200 -y 50
"$real_tmux" split-window -h -t widthtest
widthtest_pane="$("$real_tmux" list-panes -t widthtest -F '#{pane_id}' | head -n 1)"
dev-side-width "$("$real_tmux" display -p '#{socket_path},0,0')" "$widthtest_pane" lazygit
assert_contains "width log written" "$(cat "$HOME/.cache/dev/side-width.log")" "window=lazygit width=40%"

echo "== dev-stop -k"
dev-stop -k
assert_contains "containers are stopped" "$(cat "$FAKE_LOG_DIR/podman.log")" "podman stop abc123"
assert_true "tmux servers are gone" wait_for 10 bash -c "! '$real_tmux' has-session 2>/dev/null"

echo "== docker engine and shell from the config file"
mkdir -p "$HOME/.config/dev-variants"
ln -sf "$fakebin/fake-docker" "$fakebin/docker"
cat >"$HOME/.config/dev-variants/config" <<EOF
: "\${DEV_ENGINE:=docker}"
: "\${DEV_PANEL:=lazydocker}"
: "\${DEV_SHELL:=$fakebin/fake-shell}"
EOF
assert_contains "host shell comes from the config" "$(cd "$root/work/plain" && dev-in </dev/null)" "FAKE-SHELL"
mkdir -p "$root/work/dock"
(cd "$root/work/dock" && dev-c-c >/dev/null 2>&1)
docker_config="$(cat "$root/work/dock/.devcontainer/devcontainer.json")"
assert_not_contains "docker config has no keep-id" "$docker_config" "keep-id"
assert_contains "docker config updates the user id" "$docker_config" '"updateRemoteUserUID": true'
assert_contains "up uses docker" "$(tail -n 1 "$FAKE_LOG_DIR/devcontainer.log")" "up --docker-path docker"
assert_true "side panel has a docker tab" wait_for 15 side_ready dock claude docker
sleep 1
assert_contains "editor runs through docker exec" "$(pane_text -t dock:code.{top-left})" "FAKE-DOCKER-EXEC"
assert_contains "docker tab runs lazydocker" "$(pane_text -L side -t dock:docker)" "FAKE-lazydocker"
assert_contains "main session uses the chosen shell" "$("$real_tmux" show-options -t dock -v default-shell)" "fake-shell"
dev-stop -k
assert_contains "docker containers are stopped" "$(cat "$FAKE_LOG_DIR/docker.log")" "docker stop abc123"
wait_for 10 bash -c "! '$real_tmux' has-session 2>/dev/null"

"$real_tmux" kill-server 2>/dev/null || true
"$real_tmux" -L side kill-server 2>/dev/null || true
"$real_tmux" -L terminals kill-server 2>/dev/null || true
rm -rf "$root"

echo
echo "$((checks - failures))/$checks checks passed"
[ "$failures" -eq 0 ]
