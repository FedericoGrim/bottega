#!/usr/bin/env bash
set -euo pipefail

source_dir="$(cd "$(dirname "$0")" && pwd)/bin"
tmux_source_dir="$(cd "$(dirname "$0")" && pwd)/tmux"
target_dir="$HOME/.local/bin"
backup_dir="$HOME/.dev-variants-backup-$(date +%Y%m%d-%H%M%S)"
terminals_config="$HOME/.tmux-terminals.conf"
block_start="# >>> dev-variants >>>"
block_end="# <<< dev-variants <<<"
minimum_tmux_version="3.2"
old_script_names=(dev-container dev-opencode)

say() {
  printf '\n==> %s\n' "$*"
}

back_up() {
  mkdir -p "$backup_dir"
  cp -a "$1" "$backup_dir/"
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

tmux_is_recent_enough() {
  local version
  version="$(tmux -V | sed -E 's/[^0-9.]//g')"
  [ "$(printf '%s\n%s\n' "$minimum_tmux_version" "$version" | sort -V | head -n 1)" = "$minimum_tmux_version" ]
}

report_dependencies() {
  local tool
  for tool in tmux jq python3 nvim lazygit claude; do
    command -v "$tool" >/dev/null 2>&1 || echo "  missing (required): $tool"
  done
  for tool in podman devcontainer podman-tui opencode; do
    command -v "$tool" >/dev/null 2>&1 || echo "  missing (optional): $tool"
  done
  if command -v tmux >/dev/null 2>&1 && ! tmux_is_recent_enough; then
    echo "  tmux is older than $minimum_tmux_version: the container variants need 3.2 or newer"
  fi
  case ":$PATH:" in
    *":$target_dir:"*) ;;
    *) echo "  $target_dir is not in PATH" ;;
  esac
}

say "Installing scripts into $target_dir"
install_scripts
remove_old_scripts

say "Installing tmux configurations (existing ones are kept)"
install_tmux_configs

say "Updating $terminals_config"
update_terminals_config

say "Checking dependencies"
report_dependencies

[ -d "$backup_dir" ] && say "Replaced files were saved in $backup_dir"

say "Done. Try: dev --help"
