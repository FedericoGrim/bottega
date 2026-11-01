#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")" && pwd)"
source_dir="$repo_dir/bin"
tmux_source_dir="$repo_dir/tmux"
target_dir="$HOME/.local/bin"
backup_dir="$HOME/.dev-variants-backup-$(date +%Y%m%d-%H%M%S)"
terminals_config="$HOME/.tmux-terminals.conf"
user_config="${XDG_CONFIG_HOME:-$HOME/.config}/dev-variants/config"
block_start="# >>> dev-variants >>>"
block_end="# <<< dev-variants <<<"
minimum_tmux_version="3.2"
minimum_podman_version="4.3"
old_script_names=(dev-container dev-opencode)
all_envs=(dev dev-o dev-c-c dev-c-o)

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Without options it asks what to set up (or uses the previous choices when not run in a terminal).

  --envs LIST          environments to use, comma separated: dev,dev-o,dev-c-c,dev-c-o or all
  --engine NAME        container engine: podman or docker
  --panel NAME         container panel in the side bar: podman-tui or lazydocker
  --shell CHOICE       shell of the dev sessions: zsh (installs oh-my-zsh and plugins) or keep
  --yes                ask nothing, use the defaults for what is not given
  -h, --help           show this help
EOF
}

say() {
  printf '\n==> %s\n' "$*"
}

die() {
  echo "install.sh: $*" >&2
  exit 1
}

back_up() {
  mkdir -p "$backup_dir"
  cp -a "$1" "$backup_dir/"
}

load_previous_choices() {
  # shellcheck source=/dev/null
  [ -f "$user_config" ] && . "$user_config"
  : "${DEV_ENVS:=${all_envs[*]}}"
  : "${DEV_ENGINE:=podman}"
  : "${DEV_PANEL:=}"
  : "${DEV_SHELL_CHOICE:=keep}"
}

parse_arguments() {
  ask=1
  [ -t 0 ] || ask=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --envs) envs="${2:?--envs needs a value}"; shift ;;
      --engine) engine="${2:?--engine needs a value}"; shift ;;
      --panel) panel="${2:?--panel needs a value}"; shift ;;
      --shell) shell_choice="${2:?--shell needs a value}"; shift ;;
      --yes) ask=0 ;;
      -h | --help) usage; exit 0 ;;
      *) die "unknown option: $1" ;;
    esac
    shift
  done
}

ask_one() {
  local question="$1" default="$2" answer index
  shift 2
  echo >&2
  echo "$question" >&2
  for index in $(seq 1 $#); do
    echo "  $index) ${!index}" >&2
  done
  read -r -p "Choice [$default]: " answer
  if [ -z "$answer" ]; then
    printf '%s' "$default"
  elif [[ "$answer" =~ ^[0-9]+$ ]] && [ "$answer" -ge 1 ] && [ "$answer" -le $# ]; then
    printf '%s' "${!answer}"
  else
    die "invalid choice: $answer"
  fi
}

ask_envs() {
  local default="$1" answer number picked=()
  echo >&2
  echo "Which environments do you want to use? (numbers separated by commas)" >&2
  echo "  1) dev       project on the host, with Claude Code" >&2
  echo "  2) dev-o     project on the host, with OpenCode" >&2
  echo "  3) dev-c-c   project in a dev container, with Claude Code" >&2
  echo "  4) dev-c-o   project in a dev container, with OpenCode" >&2
  read -r -p "Choice [$default]: " answer
  if [ -z "$answer" ]; then
    printf '%s' "$default"
    return
  fi
  for number in ${answer//,/ }; do
    [[ "$number" =~ ^[1-4]$ ]] || die "invalid choice: $number"
    picked+=("${all_envs[$((number - 1))]}")
  done
  printf '%s' "${picked[*]}"
}

has_env() {
  [[ " $envs " == *" $1 "* ]]
}

uses_containers() {
  has_env dev-c-c || has_env dev-c-o
}

choose() {
  envs="${envs:-}"
  engine="${engine:-}"
  panel="${panel:-}"
  shell_choice="${shell_choice:-}"

  if [ -n "$envs" ]; then
    envs="${envs//,/ }"
  elif [ "$ask" = 1 ]; then
    envs="$(ask_envs "$DEV_ENVS")"
  else
    envs="$DEV_ENVS"
  fi
  [ "$envs" = "all" ] && envs="${all_envs[*]}"
  local name
  for name in $envs; do
    [[ " ${all_envs[*]} " == *" $name "* ]] || die "unknown environment: $name"
  done

  if [ -z "$engine" ]; then
    if [ "$ask" = 1 ] && uses_containers; then
      engine="$(ask_one "Which container engine do you use?" "$DEV_ENGINE" podman docker)"
    else
      engine="$DEV_ENGINE"
    fi
  fi
  case "$engine" in
    podman | docker) ;;
    *) die "unknown engine: $engine (use podman or docker)" ;;
  esac

  if [ -z "$panel" ]; then
    if [ "$engine" = "docker" ]; then
      panel="lazydocker"
    elif [ "$ask" = 1 ] && uses_containers; then
      panel="$(ask_one "Which container panel do you want in the side bar?" "${DEV_PANEL:-podman-tui}" podman-tui lazydocker)"
    else
      panel="${DEV_PANEL:-podman-tui}"
    fi
  fi
  case "$panel" in
    lazydocker) ;;
    podman-tui) [ "$engine" = "podman" ] || die "podman-tui works only with podman: use --panel lazydocker" ;;
    *) die "unknown panel: $panel (use podman-tui or lazydocker)" ;;
  esac

  if [ -z "$shell_choice" ]; then
    if [ "$ask" = 1 ]; then
      shell_choice="$(ask_one "Which shell do you want inside the dev sessions? zsh = zsh with oh-my-zsh and plugins, keep = $SHELL (your system shell does not change)" \
        "$DEV_SHELL_CHOICE" "zsh" "keep")"
    else
      shell_choice="$DEV_SHELL_CHOICE"
    fi
  fi
  case "$shell_choice" in
    zsh | keep) ;;
    *) die "unknown shell choice: $shell_choice (use zsh or keep)" ;;
  esac
}

install_scripts() {
  local source_file destination
  mkdir -p "$target_dir"
  for source_file in "$source_dir"/*; do
    [ -f "$source_file" ] || continue
    destination="$target_dir/$(basename "$source_file")"
    if [ -e "$destination" ] && ! cmp -s "$source_file" "$destination"; then
      back_up "$destination"
    fi
    cp "$source_file" "$destination"
    chmod +x "$destination"
    echo "  installed: $(basename "$source_file")"
  done
}

remove_old_scripts() {
  local name destination
  for name in "${old_script_names[@]}"; do
    destination="$target_dir/$name"
    [ -e "$destination" ] || continue
    back_up "$destination"
    rm -f "$destination"
    echo "  removed: $name"
  done
}

install_tmux_configs() {
  local source_file destination
  for source_file in "$tmux_source_dir"/*.conf; do
    destination="$HOME/.$(basename "$source_file")"
    if [ -e "$destination" ]; then
      echo "  kept: $destination"
    else
      cp "$source_file" "$destination"
      echo "  installed: $destination"
    fi
  done
}

update_terminals_config() {
  if [ ! -f "$terminals_config" ]; then
    echo "  skipped: $terminals_config does not exist (new tabs will open host shells)"
    return
  fi
  sed -i "\|$block_start|,\|$block_end|d" "$terminals_config"
  {
    echo "$block_start"
    echo 'bind -n M-n new-window -c "#{pane_current_path}" dev-in'
    echo "$block_end"
  } >>"$terminals_config"
  echo "  updated: Alt+n opens a shell in the container when the project has one"
}

set_up_zsh() {
  if ! command -v zsh >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get install -y zsh || true
    fi
    if ! command -v zsh >/dev/null 2>&1; then
      echo "  zsh could not be installed: install it with 'sudo apt install zsh' and run ./install.sh again"
      dev_shell="$SHELL"
      return
    fi
  fi
  # shellcheck source=dev-env.sh
  . "$repo_dir/dev-env.sh"
  install_ohmyzsh
  if ! grep -q 'oh-my-zsh.sh' "$HOME/.zshrc" 2>/dev/null; then
    echo "  note: ~/.zshrc does not load oh-my-zsh, so the plugins are not active"
  fi
  dev_shell="$(command -v zsh)"
}

write_user_config() {
  mkdir -p "$(dirname "$user_config")"
  cat >"$user_config" <<EOF
# Written by dev-variants install.sh: run it again to change these choices.
# Environment variables with the same names override these values.
: "\${DEV_ENVS:=$envs}"
: "\${DEV_ENGINE:=$engine}"
: "\${DEV_PANEL:=$panel}"
: "\${DEV_SHELL_CHOICE:=$shell_choice}"
: "\${DEV_SHELL:=$dev_shell}"
EOF
  echo "  saved: $user_config"
}

install_hint() {
  case "$1" in
    tmux | jq | python3 | podman) echo "sudo apt install $1" ;;
    nvim) echo "./dev-env.sh install (official tarball in /opt)" ;;
    lazygit) echo "see https://github.com/jesseduffield/lazygit#installation" ;;
    claude) echo "curl -fsSL https://claude.ai/install.sh | bash" ;;
    opencode) echo "npm i -g opencode-ai" ;;
    devcontainer) echo "npm i -g @devcontainers/cli" ;;
    docker) echo "sudo apt install docker.io && sudo usermod -aG docker \$USER (then log out and back in)" ;;
    podman-tui) echo "./dev-env.sh install --containers (builds it for your Podman version)" ;;
    lazydocker) echo "curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash" ;;
  esac
}

check_tool() {
  if command -v "$1" >/dev/null 2>&1; then
    echo "  ok: $1"
  else
    echo "  missing: $1  ->  $(install_hint "$1")"
  fi
}

version_at_least() {
  [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n 1)" = "$1" ]
}

check_podman() {
  local version
  if ! command -v podman >/dev/null 2>&1; then
    check_tool podman
    return
  fi
  version="$(podman --version | awk '{print $3}')"
  if version_at_least "$minimum_podman_version" "$version"; then
    echo "  ok: podman $version"
  else
    echo "  podman $version is older than $minimum_podman_version: --userns=keep-id needs a newer Podman"
  fi
  if [ "$panel" = "lazydocker" ] && ! systemctl --user is-active --quiet podman.socket 2>/dev/null; then
    echo "  lazydocker needs the Podman socket  ->  systemctl --user enable --now podman.socket"
  fi
}

check_docker() {
  check_tool docker
  if command -v docker >/dev/null 2>&1 && ! docker info >/dev/null 2>&1; then
    echo "  docker does not answer  ->  sudo systemctl enable --now docker, and check that you are in the docker group"
  fi
}

report_dependencies() {
  local tool
  for tool in tmux jq python3 nvim lazygit; do
    check_tool "$tool"
  done
  if has_env dev || has_env dev-c-c; then
    check_tool claude
  fi
  if has_env dev-o || has_env dev-c-o; then
    check_tool opencode
  fi
  if uses_containers; then
    "check_$engine"
    check_tool devcontainer
    check_tool "$panel"
    if command -v tmux >/dev/null 2>&1 && ! version_at_least "$minimum_tmux_version" "$(tmux -V | sed -E 's/[^0-9.]//g')"; then
      echo "  tmux is older than $minimum_tmux_version: the container environments need 3.2 or newer"
    fi
  fi
  case ":$PATH:" in
    *":$target_dir:"*) ;;
    *) echo "  $target_dir is not in PATH" ;;
  esac
}

parse_arguments "$@"
load_previous_choices
choose

say "Installing scripts into $target_dir"
install_scripts
remove_old_scripts

say "Installing tmux configurations (existing ones are kept)"
install_tmux_configs

say "Updating $terminals_config"
update_terminals_config

dev_shell="$SHELL"
if [ "$shell_choice" = "zsh" ]; then
  say "Setting up zsh for the dev sessions"
  set_up_zsh
fi

say "Saving your choices"
write_user_config

say "Checking dependencies"
report_dependencies

[ -d "$backup_dir" ] && say "Replaced files were saved in $backup_dir"

say "Done. Try: ${envs// /, } (dev --help lists every command)"
