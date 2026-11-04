#!/usr/bin/env bash
# dev-env.sh — esporta e reinstalla il mio ambiente di sviluppo da terminale.
#
#   ./dev-env.sh export [--claude-settings]
#       Sul PC di partenza: raccoglie le configurazioni vere e un inventario,
#       e crea ~/dev-env-DATA.tar.gz (contiene anche questo script).
#
#   ./dev-env.sh install [--containers] [--languages] [--flutter]
#       Sul PC nuovo (Debian, Ubuntu, Mint): installa gli strumenti e rimette
#       al loro posto le configurazioni esportate.
#
# Non include segreti: niente chiavi SSH, token, ~/.claude/.credentials.json,
# dati dei container. Il file ~/.claude/settings.json va richiesto a parte
# con --claude-settings, perché può contenere variabili private.

set -euo pipefail

SELF="$(readlink -f "${BASH_SOURCE[0]}")"
HERE="$(dirname "$SELF")"
STAMP="$(date +%F)"

# File e cartelle da esportare, relativi alla home.
FILES=(
  .tmux.conf
  .tmux-terminals.conf
  .tmux-side.conf
  .local/bin/dev
  .local/bin/dev-stop
  .local/bin/dev-side
  .local/bin/dev-side-width
  .local/bin/dev-c-c
  .local/bin/dev-c-o
  .local/bin/dev-o
  .local/bin/dev-up
  .local/bin/dev-guard
  .local/bin/dev-in
  .local/bin/dev-svc
  .local/bin/dev-personal-setup
  .local/bin/dctl
  .config/lazygit/config.yml
  .config/mise/config.toml
  .claude/CLAUDE.md
)
DIRS=(
  .config/nvim
  .claude/skills
  .claude/commands
  .claude/agents
)

say()  { printf '\n==> %s\n' "$*"; }
warn() { printf '!! %s\n' "$*" >&2; }
die()  { warn "$*"; exit 1; }

usage() {
  cat <<'EOF'
Uso:
  ./dev-env.sh export [--claude-settings]
  ./dev-env.sh install [--containers] [--languages] [--flutter]

export   crea ~/dev-env-DATA.tar.gz con le tue configurazioni e un inventario
install  installa gli strumenti e applica le configurazioni (da lanciare dentro
         la cartella dev-env/ estratta dall'archivio)

--containers   in più: Podman, socket, docker-compose, mise, Node, devcontainer
               CLI e podman-tui (compilato per la tua versione di Podman)
--languages    in più: Java, Maven, Python, .NET, Go, Node, Rust e pnpm
--flutter      in più: Flutter e le librerie per le app desktop Linux
EOF
}

# ---------------------------------------------------------------- export ----

ver() {
  local c="$1"
  shift
  if command -v "$c" >/dev/null 2>&1; then
    printf '%-16s %s\n' "$c" "$("$c" "$@" 2>&1 | head -n1 || true)"
  else
    printf '%-16s %s\n' "$c" "non installato"
  fi
}

write_manifest() {
  local root="$1"
  {
    echo "# Riepilogo ambiente - $STAMP"
    echo
    echo "## Sistema"
    if [ -r /etc/os-release ]; then
      # shellcheck disable=SC1091
      (. /etc/os-release && echo "$PRETTY_NAME")
    fi
    echo "Shell: ${SHELL:-sconosciuta}"
    if [ -f "$HOME/.zshrc" ]; then
      grep -E '^(ZSH_THEME|plugins=)' "$HOME/.zshrc" || true
    fi
    echo
    echo "## Versioni"
    ver tmux -V
    ver nvim --version
    ver lazygit --version
    ver claude --version
    ver git --version
    ver zsh --version
    ver podman --version
    ver podman-tui version
    ver docker-compose version
    ver mise --version
    ver uv --version
    ver node --version
    ver pnpm --version
    ver python3 --version
    ver java -version
    ver mvn --version
    ver go version
    ver rustc --version
    ver cargo --version
    ver dotnet --version
    ver gh --version
    ver flutter --version
    ver btop --version
    ver zoxide --version
    ver bat --version
    ver eza --version
    ver delta --version
    ver direnv version
    ver shellcheck --version
    ver jq --version
    echo
    echo "## Programmi personali in ~/.local/bin"
    if [ -d "$HOME/.local/bin" ]; then
      ls -1 "$HOME/.local/bin" || true
    fi
    echo
    echo "## Strumenti installati con pipx"
    if command -v pipx >/dev/null 2>&1; then
      pipx list --short 2>/dev/null || true
    else
      echo "pipx non installato"
    fi
    echo
    echo "## Pacchetti npm globali"
    if command -v npm >/dev/null 2>&1; then
      npm ls -g --depth=0 2>/dev/null || true
    else
      echo "npm non installato"
    fi
    if command -v podman >/dev/null 2>&1; then
      echo
      echo "## Podman: immagini"
      podman images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null || true
      echo
      echo "## Podman: container"
      podman ps -a --format '{{.Names}}  {{.Image}}' 2>/dev/null || true
      echo
      echo "## Podman: volumi (solo i nomi, i dati non vengono esportati)"
      podman volume ls --format '{{.Name}}' 2>/dev/null || true
    fi
  } > "$root/manifest.txt"
}

filter_gitconfig() {
  grep -E '^(user\.name|user\.email|init\.defaultbranch|core\.editor|core\.pager|interactive\.difffilter|merge\.conflictstyle|delta\.|alias\.)'
}

# La config di mise può avere una sezione [env] con variabili private: si esporta solo [tools].
keep_mise_tools_only() {
  local file="$1" tmp
  tmp="$(mktemp)"
  awk '/^\[/ { in_tools = ($0 ~ /^\[tools(\]|\.)/) } in_tools' "$file" > "$tmp"
  mv "$tmp" "$file"
}

export_env() {
  local with_claude_settings=0 a
  for a in "$@"; do
    case "$a" in
      --claude-settings) with_claude_settings=1 ;;
      *) die "opzione sconosciuta: $a" ;;
    esac
  done

  local stage root item
  stage="$(mktemp -d)"
  root="$stage/dev-env"
  mkdir -p "$root/files"

  say "Raccolgo le configurazioni"
  for item in "${FILES[@]}" "${DIRS[@]}"; do
    if [ -e "$HOME/$item" ]; then
      tar -C "$HOME" --exclude=.git -cf - "$item" | tar -C "$root/files" -xf -
      echo "  incluso: $item"
    else
      echo "  assente: $item"
    fi
  done

  if [ -f "$root/files/.config/mise/config.toml" ]; then
    keep_mise_tools_only "$root/files/.config/mise/config.toml"
    echo "  mise: esportata solo la sezione [tools]"
  fi

  if [ "$with_claude_settings" = 1 ]; then
    if [ -f "$HOME/.claude/settings.json" ]; then
      tar -C "$HOME" -cf - .claude/settings.json | tar -C "$root/files" -xf -
      echo "  incluso: .claude/settings.json (controllalo: può contenere dati privati)"
    fi
  fi

  say "Salvo le impostazioni di Git (nome, email, editor, alias, delta e stile dei conflitti)"
  git config --global --list 2>/dev/null | filter_gitconfig > "$root/gitconfig.txt" || true

  if [ -f "$HOME/.zshrc" ]; then
    say "Salvo una copia di .zshrc da rivedere a mano (senza le righe con parole come key, token, secret)"
    {
      echo "# Copia di ~/.zshrc solo da consultare: non viene applicata."
      echo "# Le righe con key, token, secret, password, credential sono state tolte."
      grep -viE 'key|token|secret|password|passwd|credential' "$HOME/.zshrc" || true
    } > "$root/zshrc.review"
  fi

  say "Scrivo l'inventario"
  write_manifest "$root"
  if command -v apt-mark >/dev/null 2>&1; then
    apt-mark showmanual | sort > "$root/apt-manual.txt" || true
  fi

  if [ -f "$HERE/README.md" ]; then
    cp "$HERE/README.md" "$root/README.md"
  fi
  cp "$SELF" "$root/dev-env.sh"
  chmod +x "$root/dev-env.sh"

  local out="$HOME/dev-env-$STAMP.tar.gz"
  tar -C "$stage" -czf "$out" dev-env
  chmod 600 "$out"
  rm -rf "$stage"

  say "Fatto"
  echo "Archivio: $out ($(du -h "$out" | cut -f1))"
  echo "Contiene le tue configurazioni: non pubblicarlo. Controlla zshrc.review prima di copiare qualcosa."
  echo "Sul PC nuovo: tar xzf $(basename "$out") && cd dev-env && ./dev-env.sh install"
}

# --------------------------------------------------------------- install ----

install_packages() {
  say "Pacchetti di sistema"
  sudo apt-get update
  sudo apt-get install -y git curl unzip xz-utils zip build-essential pkg-config \
    ripgrep fd-find fzf tmux zsh btop zoxide shellcheck jq xclip
  if command -v fdfind >/dev/null 2>&1; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
}

install_neovim() {
  if [ -x /opt/nvim-linux-x86_64/bin/nvim ]; then
    echo "Neovim già presente in /opt"
    return 0
  fi
  say "Neovim (versione ufficiale in /opt)"
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/nvim.tar.gz" https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo rm -rf /opt/nvim-linux-x86_64
  sudo tar -C /opt -xzf "$tmp/nvim.tar.gz"
  rm -rf "$tmp"
}

install_treesitter() {
  if command -v tree-sitter >/dev/null 2>&1; then
    echo "tree-sitter già presente"
    return 0
  fi
  say "tree-sitter CLI"
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/ts.gz" https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz
  gunzip -c "$tmp/ts.gz" > "$tmp/tree-sitter"
  install -m 755 "$tmp/tree-sitter" "$HOME/.local/bin/tree-sitter"
  rm -rf "$tmp"
}

install_lazygit() {
  if command -v lazygit >/dev/null 2>&1; then
    echo "lazygit già presente"
    return 0
  fi
  say "lazygit"
  local v arch tmp
  v="$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')"
  [ -n "$v" ] || die "non riesco a leggere l'ultima versione di lazygit"
  arch="$(uname -m | sed -e 's/aarch64/arm64/')"
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/lazygit.tar.gz" "https://github.com/jesseduffield/lazygit/releases/download/v${v}/lazygit_${v}_Linux_${arch}.tar.gz"
  tar -C "$tmp" -xf "$tmp/lazygit.tar.gz" lazygit
  sudo install "$tmp/lazygit" -D -t /usr/local/bin/
  rm -rf "$tmp"
}

install_claude() {
  if command -v claude >/dev/null 2>&1; then
    echo "Claude Code già presente"
    return 0
  fi
  say "Claude Code (installer ufficiale)"
  curl -fsSL https://claude.ai/install.sh | bash
}

install_font() {
  if ! command -v fc-list >/dev/null 2>&1; then
    warn "fontconfig non trovato: salto il Nerd Font"
    return 0
  fi
  if fc-list | grep -qi 'JetBrainsMono Nerd'; then
    echo "JetBrainsMono Nerd Font già presente"
    return 0
  fi
  say "JetBrainsMono Nerd Font"
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/font.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  mkdir -p "$HOME/.local/share/fonts/JetBrainsMono"
  unzip -o -q "$tmp/font.zip" -d "$HOME/.local/share/fonts/JetBrainsMono"
  fc-cache -f
  rm -rf "$tmp"
  echo "Ricordati di scegliere il font nelle preferenze del terminale."
}

install_ohmyzsh() {
  say "oh-my-zsh e plugin"
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  if [ ! -d "$custom/plugins/zsh-autosuggestions" ]; then
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$custom/plugins/zsh-autosuggestions"
  fi
  if [ ! -d "$custom/plugins/fast-syntax-highlighting" ]; then
    git clone --depth 1 https://github.com/zdharma-continuum/fast-syntax-highlighting "$custom/plugins/fast-syntax-highlighting"
  fi
  if grep -q '^plugins=' "$HOME/.zshrc" 2>/dev/null; then
    sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions fzf fast-syntax-highlighting)/' "$HOME/.zshrc"
  fi
}

apply_files() {
  local src="$HERE/files"
  if [ ! -d "$src" ]; then
    warn "cartella files/ non trovata: salto le configurazioni"
    return 0
  fi
  say "Configurazioni (le versioni diverse già presenti vanno in un backup)"
  local backup f
  backup="$HOME/.dev-env-backup-$(date +%Y%m%d-%H%M%S)"
  while IFS= read -r -d '' f; do
    f="${f#./}"
    if [ -e "$HOME/$f" ]; then
      if ! cmp -s "$src/$f" "$HOME/$f"; then
        mkdir -p "$backup/$(dirname "$f")"
        cp -a "$HOME/$f" "$backup/$f"
      fi
    fi
    mkdir -p "$HOME/$(dirname "$f")"
    cp -a "$src/$f" "$HOME/$f"
    echo "  applicato: $f"
  done < <(cd "$src" && find . -type f -print0)

  chmod +x "$HOME"/.local/bin/dev* "$HOME/.local/bin/dctl" 2>/dev/null || true

  if [ ! -f "$HOME/.config/nvim/init.lua" ]; then
    say "Nessuna configurazione di Neovim esportata: installo il LazyVim starter"
    mkdir -p "$HOME/.config"
    git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
    rm -rf "$HOME/.config/nvim/.git"
  fi
  if [ -d "$backup" ]; then
    echo "Backup dei file sostituiti: $backup"
  fi
}

write_zshrc_block() {
  say "Righe da aggiungere a ~/.zshrc"
  local rc="$HOME/.zshrc"
  touch "$rc"
  sed -i '/# >>> dev-env >>>/,/# <<< dev-env <<</d' "$rc"
  # shellcheck disable=SC2016
  {
    echo '# >>> dev-env >>>'
    echo 'export PATH="$HOME/.local/bin:$PATH"'
    echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"'
    echo 'command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"'
    echo '[ -x "$HOME/.local/bin/mise" ] && eval "$($HOME/.local/bin/mise activate zsh)"'
    echo 'command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"'
    echo '[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"'
    echo '[ -d "$HOME/develop/flutter/bin" ] && export PATH="$HOME/develop/flutter/bin:$PATH"'
    echo '# <<< dev-env <<<'
  } >> "$rc"
}

replay_gitconfig() {
  local f="$HERE/gitconfig.txt" k v
  if [ ! -f "$f" ]; then
    return 0
  fi
  say "Impostazioni di Git"
  while IFS='=' read -r k v; do
    if [ -z "$k" ]; then
      continue
    fi
    case "$k" in
      core.pager|interactive.difffilter)
        if ! command -v delta >/dev/null 2>&1; then
          warn "delta non installato: salto $k"
          continue
        fi
        ;;
    esac
    git config --global "$k" "$v"
    echo "  $k"
  done < "$f"
}

ensure_mise() {
  if [ ! -x "$HOME/.local/bin/mise" ]; then
    curl -fsSL https://mise.run | sh
  fi
}

install_cli_tools() {
  say "Strumenti da terminale (bat, eza, delta, direnv, uv)"
  ensure_mise
  if [ -f "$HOME/.config/mise/config.toml" ]; then
    "$HOME/.local/bin/mise" install
  fi
  "$HOME/.local/bin/mise" use -g bat eza delta direnv uv
}

install_dotnet() {
  if apt-cache policy dotnet-sdk-10.0 2>/dev/null | grep -q 'Candidate: [0-9]'; then
    sudo apt-get install -y dotnet-sdk-10.0
  else
    warn "dotnet-sdk-10.0 non è nei repository di questo sistema: installalo a mano (https://learn.microsoft.com/dotnet/core/install/linux)"
  fi
}

install_rust() {
  if [ -x "$HOME/.cargo/bin/rustup" ]; then
    echo "Rust già presente"
    return 0
  fi
  say "Rust (rustup)"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile default -c rust-analyzer
}

enable_pnpm() {
  "$HOME/.local/bin/mise" exec node@lts -- corepack enable --install-directory "$HOME/.local/bin" pnpm
}

install_languages() {
  say "Linguaggi: Java, Python, .NET, Go, Node, Rust e pnpm"
  sudo apt-get install -y openjdk-21-jdk maven python3 python3-venv python3-pip
  install_dotnet
  ensure_mise
  "$HOME/.local/bin/mise" use -g go@latest node@lts
  install_rust
  enable_pnpm
}

install_containers() {
  say "Podman e strumenti per i DevContainer"
  sudo apt-get install -y podman golang-go make \
    libgpgme-dev libdevmapper-dev libassuan-dev libbtrfs-dev libseccomp-dev
  systemctl --user enable --now podman.socket || warn "socket di Podman non attivato"

  if [ ! -x "$HOME/.local/bin/docker-compose" ]; then
    curl -fsSL -o "$HOME/.local/bin/docker-compose" https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64
    chmod +x "$HOME/.local/bin/docker-compose"
  fi

  ensure_mise
  "$HOME/.local/bin/mise" use -g node@lts
  "$HOME/.local/bin/mise" exec node@lts -- npm install -g @devcontainers/cli

  install_podman_tui
}

install_podman_tui() {
  # La serie di podman-tui deve avere il numero maggiore di Podman meno 4:
  # Podman 4 -> v0.x, Podman 5 -> v1.x, Podman 6 -> v2.x.
  local major series src tag
  major="$(podman --version | awk '{print $3}' | cut -d. -f1)"
  series=$((major - 4))
  if [ "$series" -lt 0 ]; then
    warn "versione di Podman troppo vecchia per podman-tui: salto"
    return 0
  fi
  src="$HOME/src/podman-tui"
  mkdir -p "$HOME/src"
  if [ ! -d "$src/.git" ]; then
    git clone https://github.com/containers/podman-tui.git "$src"
  fi
  git -C "$src" fetch --tags -q
  tag="$(git -C "$src" tag --list "v${series}.*" | sort -V | tail -n1)"
  if [ -z "$tag" ]; then
    warn "nessun tag v${series}.* trovato: salto podman-tui"
    return 0
  fi
  say "podman-tui $tag (per Podman $major)"
  git -C "$src" checkout -q "$tag"
  (cd "$src" && make binary)
  install -D "$src/bin/podman-tui" "$HOME/.local/bin/podman-tui"
}

install_flutter() {
  say "Flutter"
  sudo apt-get install -y libglu1-mesa clang cmake ninja-build libgtk-3-dev
  mkdir -p "$HOME/develop"
  if [ ! -d "$HOME/develop/flutter" ]; then
    git clone https://github.com/flutter/flutter.git -b stable "$HOME/develop/flutter"
  fi
}

install_completions() {
  local d="$HOME/.oh-my-zsh/completions"
  mkdir -p "$d"
  if command -v podman >/dev/null 2>&1; then
    podman completion zsh > "$d/_podman" || true
  fi
  if command -v gh >/dev/null 2>&1; then
    gh completion -s zsh > "$d/_gh" || true
  fi
  rm -f "$HOME"/.zcompdump*
}

NVIM_BIN="${NVIM_BIN:-/opt/nvim-linux-x86_64/bin/nvim}"

# Il registry personalizzato di roslyn può puntare a una release che non esiste ancora:
# in quel caso si ripiega su questa versione, che esiste su GitHub.
ROSLYN_FALLBACK_VERSION="5.14.0-1.26552.12"

NVIM_PARSERS=(
  bash c c_sharp css diff dockerfile fsharp git_config git_rebase gitattributes gitcommit gitignore
  go gomod gosum gowork html java javascript json json5 lua luadoc markdown markdown_inline ninja
  python query regex ron rst rust sql toml tsx typescript vim vimdoc xml yaml
)

NVIM_MASON_PACKAGES=(
  codelldb csharpier debugpy delve docker-compose-language-service dockerfile-language-server
  eslint_d fantomas gofumpt goimports golangci-lint gopls hadolint java-debug-adapter java-test
  jdtls js-debug-adapter json-lsp lua-language-server markdown-toc markdownlint-cli2 marksman
  netcoredbg prettier pyright ruff rust-analyzer shfmt stylua taplo vtsls yaml-language-server
)

lua_list() {
  local item
  printf '{ '
  for item in "$@"; do
    printf '"%s", ' "$item"
  done
  printf '}'
}

write_nvim_tools_script() {
  local file="$1"
  cat > "$file" <<LUA
require("lazy").load({ plugins = { "nvim-treesitter", "mason.nvim" } })

local parsers = $(lua_list "${NVIM_PARSERS[@]}")
local packages = $(lua_list "${NVIM_MASON_PACKAGES[@]}")
local roslyn_fallback = "$ROSLYN_FALLBACK_VERSION"

require("nvim-treesitter").install(parsers):wait(1800000)

local registry = require("mason-registry")
local pending = 0

local function install(name, version, on_failure)
  local ok, package = pcall(registry.get_package, name)
  if not ok or (package:is_installed() and not version) then
    return
  end
  pending = pending + 1
  package:install({ version = version }, function(success, error)
    pending = pending - 1
    if not success then
      print(name .. " non installato: " .. tostring(error))
      if on_failure then
        on_failure()
      end
    end
  end)
end

registry.refresh(function()
  for _, name in ipairs(packages) do
    install(name)
  end
  install("roslyn", nil, function()
    install("roslyn", roslyn_fallback)
  end)
end)

vim.wait(1800000, function()
  return #registry.get_installed_package_names() > 0 and pending == 0
end, 500)
vim.cmd("qa!")
LUA
}

sync_nvim() {
  if [ ! -x "$NVIM_BIN" ]; then
    return 0
  fi
  say "Scarico i plugin di LazyVim (può richiedere qualche minuto)"
  "$NVIM_BIN" --headless "+Lazy! sync" +qa || warn "sincronizzazione dei plugin non completata: apri nvim e controlla con :Lazy"

  say "Installo parser, server e debugger (può richiedere diversi minuti)"
  local script
  script="$(mktemp --suffix=.lua)"
  write_nvim_tools_script "$script"
  "$NVIM_BIN" --headless -c "luafile $script" || warn "installazione di server e parser non completata: apri nvim e controlla con :Mason"
  rm -f "$script"
}

final_notes() {
  say "Fatto. Restano da fare a mano:"
  cat <<'EOF'
  1. Rendere zsh la shell predefinita:        chsh -s "$(command -v zsh)"   (poi esci e rientra)
  2. Scegliere "JetBrainsMono Nerd Font" nelle preferenze del terminale
  3. Accedere a GitHub (installa prima gh):    gh auth login
  4. Accedere a Claude Code:                   claude
  5. Rimettere le chiavi SSH, se le usi
  6. Aprire un terminale nuovo e provare:      dev
  7. Controllare le righe di ~/.zshrc che non sono state copiate (zshrc.review)
EOF
}

install_env() {
  local with_containers=0 with_languages=0 with_flutter=0 a
  for a in "$@"; do
    case "$a" in
      --containers) with_containers=1 ;;
      --languages) with_languages=1 ;;
      --flutter) with_flutter=1 ;;
      *) die "opzione sconosciuta: $a" ;;
    esac
  done

  if [ "$(id -u)" -eq 0 ]; then
    die "lancialo come utente normale: usa sudo da solo quando serve"
  fi
  command -v apt-get >/dev/null 2>&1 || die "serve un sistema con apt (Debian, Ubuntu, Mint)"
  mkdir -p "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"

  install_packages
  install_neovim
  install_treesitter
  install_lazygit
  install_claude
  install_font
  install_ohmyzsh
  apply_files
  write_zshrc_block
  install_cli_tools
  replay_gitconfig
  if [ "$with_containers" = 1 ]; then
    install_containers
  fi
  if [ "$with_languages" = 1 ]; then
    install_languages
  fi
  if [ "$with_flutter" = 1 ]; then
    install_flutter
  fi
  install_completions
  export PATH="$HOME/.local/share/mise/shims:$HOME/.cargo/bin:$PATH"
  sync_nvim
  final_notes
}

main() {
  case "${1:-}" in
    export) shift; export_env "$@" ;;
    install) shift; install_env "$@" ;;
    *) usage ;;
  esac
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi
