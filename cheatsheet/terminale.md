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
| `mise use -g node@lts` | installa Node LTS per tutto il PC |
| `npm install -g @devcontainers/cli` | installa la CLI dei DevContainer |
| `sudo apt install xclip` | appunti di sistema per Neovim e per questa guida |
