#!/usr/bin/env bash
# dev-env.sh — esporta e reinstalla il mio ambiente di sviluppo da terminale.
#
#   ./dev-env.sh export [--claude-settings]
#       Sul PC di partenza: raccoglie le configurazioni vere e un inventario,
#       e crea ~/dev-env-DATA.tar.gz (contiene anche questo script).
#
#   ./dev-env.sh install [--containers] [--flutter]
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
  .local/bin/dev-container
  .local/bin/dev-opencode
  .local/bin/dev-up
  .local/bin/dev-guard
  .local/bin/dev-in
  .local/bin/dev-svc
  .local/bin/dev-personal-setup
  .local/bin/dctl
  .config/lazygit/config.yml
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
  ./dev-env.sh install [--containers] [--flutter]

export   crea ~/dev-env-DATA.tar.gz con le tue configurazioni e un inventario
install  installa gli strumenti e applica le configurazioni (da lanciare dentro
         la cartella dev-env/ estratta dall'archivio)

--containers   in più: Podman, socket, docker-compose, mise, Node, devcontainer
               CLI e podman-tui (compilato per la tua versione di Podman)
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
    ver node --version
    ver go version
    ver gh --version
    ver flutter --version
    ver btop --version
    ver zoxide --version
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

  if [ "$with_claude_settings" = 1 ]; then
    if [ -f "$HOME/.claude/settings.json" ]; then
      tar -C "$HOME" -cf - .claude/settings.json | tar -C "$root/files" -xf -
      echo "  incluso: .claude/settings.json (controllalo: può contenere dati privati)"
    fi
  fi

  say "Salvo le impostazioni di Git (solo nome, email, editor e alias)"
  git config --global --list 2>/dev/null \
    | grep -E '^(user\.name|user\.email|init\.defaultbranch|core\.editor|alias\.)' \
    > "$root/gitconfig.txt" || true

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
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
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
    if [ -n "$k" ]; then
      git config --global "$k" "$v"
      echo "  $k"
    fi
  done < "$f"
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

  if [ ! -x "$HOME/.local/bin/mise" ]; then
    curl -fsSL https://mise.run | sh
  fi
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

sync_nvim() {
  local nv=/opt/nvim-linux-x86_64/bin/nvim
  if [ -x "$nv" ]; then
    say "Scarico i plugin di LazyVim (può richiedere qualche minuto)"
    "$nv" --headless "+Lazy! sync" +qa || warn "sincronizzazione dei plugin non completata: apri nvim e controlla con :Lazy"
  fi
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
  local with_containers=0 with_flutter=0 a
  for a in "$@"; do
    case "$a" in
      --containers) with_containers=1 ;;
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
  replay_gitconfig
  if [ "$with_containers" = 1 ]; then
    install_containers
  fi
  if [ "$with_flutter" = 1 ]; then
    install_flutter
  fi
  install_completions
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
