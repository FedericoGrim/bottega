# Terminale

## Shell

| Comando | Cosa fa |
| --- | --- |
| `exec zsh` | ricarica la shell dopo aver cambiato ~/.zshrc; lancialo da solo |
| `~/.zshrc` | qui vanno PATH e configurazioni, mai in ~/.bashrc |
| `grep '^plugins=' ~/.zshrc` | controlla i plugin di oh-my-zsh attivi |
| `Ctrl+r` | plugin fzf: cerca nella cronologia per qualsiasi pezzo di testo |
| `Ctrl+t` | plugin fzf: cerca un file della cartella corrente |
| `Alt+c` | plugin fzf: entra in una cartella |
| `z nome` | zoxide: va in una cartella già visitata con cd |
| `zi` | zoxide: elenco filtrabile delle cartelle conosciute |
| `btop` | CPU, RAM e processi; q per uscire |
| `jq` | legge e filtra JSON |
| `shellcheck script.sh` | controlla uno script bash |
| `sudo apt install -y btop zoxide shellcheck jq fzf` | installa gli strumenti di base |
| `eval "$(zoxide init zsh)"` | riga da aggiungere a ~/.zshrc per zoxide |

## Strumenti da riga di comando

| Comando | Cosa fa |
| --- | --- |
| `bat file` | mostra un file con colori e numeri di riga |
| `bat -p file` | solo il contenuto, senza decorazioni (utile per copiare) |
| `eza -l --git` | elenco con permessi, dimensioni e stato git |
| `eza -la --git --icons` | come sopra, con file nascosti e icone |
| `eza --tree -L 2` | albero della cartella a due livelli |
| `direnv allow` | autorizza il file .envrc della cartella |
| `direnv deny` | revoca l'autorizzazione del .envrc |
| `echo 'export CHIAVE=valore' > .envrc` | variabile attiva solo dentro quella cartella |
| `mise ls` | strumenti installati con mise e le loro versioni |
| `mise use -g nome` | installa uno strumento per tutto il PC |
| `mise use nome@versione` | versione fissata per la cartella (crea mise.toml) |
| `mise upgrade` | aggiorna gli strumenti gestiti da mise |
| `mise exec node@lts -- comando` | esegue un comando con quella versione, senza attivarla |
| `starship explain` | spiega cosa mostra ogni parte del prompt |
| `starship config` | apre ~/.config/starship.toml nell'editor |
| `starship preset --list` | elenco dei temi pronti |
| `starship preset gruvbox-rainbow -o ~/.config/starship.toml` | applica un tema pronto |
| `starship timings` | quali parti del prompt lo rallentano |
| `starship toggle docker_context` | spegne o riaccende un modulo del prompt |

## Sicurezza

| Comando | Cosa fa |
| --- | --- |
| `gitleaks` | trova password e chiavi nei file e nei commit |
| `pre-commit install` | attiva i controlli (es. gitleaks) prima di ogni commit |
| `pre-commit run --all-files` | lancia i controlli su tutto il progetto |
| `npm audit` | vulnerabilità note nelle dipendenze Node, prima di ogni rilascio |
| `pip-audit -r requirements.txt` | vulnerabilità note nelle dipendenze Python |
| `trivy image --input immagine.tar` | vulnerabilità in un'immagine salvata con podman save |
| `sudo lynis audit system` | punti deboli del sistema, con consigli |

## Strumenti di Bottega

| Comando | Cosa fa |
| --- | --- |
| `curl https://mise.run \| sh` | installa mise, per gestire le versioni di Node e altri |
| `eval "$(mise activate zsh)"` | riga da aggiungere a ~/.zshrc per attivare mise |
| `eval "$(direnv hook zsh)"` | riga da aggiungere a ~/.zshrc per direnv |
| `eval "$(starship init zsh)"` | riga da aggiungere in fondo a ~/.zshrc per il prompt starship |
| `./dev-env.sh install --languages` | installa Java, Python, .NET, Go, Node, Rust e pnpm |
| `mise use -g node@lts` | installa Node LTS per tutto il PC |
| `npm install -g @devcontainers/cli` | installa la CLI dei DevContainer |
| `sudo apt install xclip` | appunti di sistema per Neovim e per questa guida |
