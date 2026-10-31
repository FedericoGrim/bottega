# dev-variants

Il mio ambiente di sviluppo da terminale: un comando `dev` che apre in tmux LazyVim, l'agente AI (Claude Code o OpenCode), lazygit, podman-tui e i terminali, sul PC o dentro un dev container.

- [Come è fatto lo schermo](#come-è-fatto-lo-schermo)
- [Installazione](#installazione)
- [Comandi](#comandi)
- [Tasti](#tasti)
- [Dev container: come funzionano](#dev-container-come-funzionano)
- [Creare un progetto con il dev container](#creare-un-progetto-con-il-dev-container)
- [Aprire il dev container di qualcun altro](#aprire-il-dev-container-di-qualcun-altro)
- [Dove gira cosa](#dove-gira-cosa)
- [Protezione dev-guard](#protezione-dev-guard)
- [Configurazione personale nel container](#configurazione-personale-nel-container)
- [Spostare tutto su un PC nuovo: dev-env.sh](#spostare-tutto-su-un-pc-nuovo-dev-envsh)
- [Problemi comuni](#problemi-comuni)
- [Disinstallare o tornare indietro](#disinstallare-o-tornare-indietro)
- [Sicurezza](#sicurezza)
- [Test](#test)
- [Cosa non è ancora provato](#cosa-non-è-ancora-provato)

## Come è fatto lo schermo

`dev` crea una sessione tmux con il nome della cartella del progetto:

```
┌──────────────────────────────┬─────────────┐
│                              │ 1 claude    │
│  LazyVim                     │ 2 lazygit   │
│                              │ 3 podman    │
│                              │             │
├──────────────────────────────┤  (pannello  │
│  terminali (Alt+n nuovo)     │  laterale)  │
└──────────────────────────────┴─────────────┘
```

- **Editor**: LazyVim.
- **Terminali** in basso: una sessione tmux a parte (`-L terminals`) con le sue schede.
- **Pannello laterale** a destra: una terza sessione tmux (`-L side`) con tre schede: agente, lazygit, podman-tui. Se `podman-tui` non c'è, al suo posto gira `watch podman ps -a`. La larghezza del pannello cambia con la scheda: agente 30% (OpenCode 35%), lazygit 40%, podman 55%.

Se la sessione esiste già, `dev` ci rientra invece di crearne una nuova.

## Installazione

```bash
git clone https://github.com/FedericoGrim/dev-variants.git
cd dev-variants
./install.sh
```

`install.sh`:

1. copia gli script di `bin/` in `~/.local/bin`. Se c'è già un file diverso con lo stesso nome, prima lo salva in `~/.dev-variants-backup-DATA/`;
2. copia le configurazioni di tmux da `tmux/` in `~/.tmux.conf`, `~/.tmux-side.conf` e `~/.tmux-terminals.conf`, **solo se mancano**: quelle che hai già restano come sono;
3. aggiunge a `~/.tmux-terminals.conf` un blocco che fa aprire `dev-in` con `Alt+n`;
4. elenca i programmi che mancano.

Si può rilanciare quando vuoi, per esempio dopo un `git pull`: il blocco in `~/.tmux-terminals.conf` non viene duplicato.

### Cosa serve

| Programma | Serve per | Come si installa |
| --- | --- | --- |
| tmux 3.2 o più recente | tutto | `sudo apt install tmux` |
| jq, python3 | tutto | `sudo apt install jq python3` |
| Neovim ufficiale + LazyVim | editor | tarball in `/opt` (vedi `dev-env.sh`). Quello dei pacchetti di sistema non va bene per il container |
| lazygit | pannello laterale | vedi `dev-env.sh` |
| Claude Code | agente | `curl -fsSL https://claude.ai/install.sh \| bash` |
| podman | container | `sudo apt install podman` |
| CLI `devcontainer` | container | `npm i -g @devcontainers/cli` |
| podman-tui | pannello laterale (facoltativo) | `dev-env.sh install --containers` |
| OpenCode | `dev-opencode` (facoltativo) | `npm i -g opencode-ai` |
| docker-compose | solo i dev container basati su compose | vedi `dev-env.sh` |

`~/.local/bin` deve essere nel `PATH`.

## Comandi

### Avviare l'ambiente

| Comando | Cosa fa |
| --- | --- |
| `dev [cartella]` | apre l'ambiente per la cartella indicata (o quella corrente). Agente predefinito: Claude Code |
| `dev --agent opencode` | come sopra, con OpenCode al posto di Claude |
| `dev --container` | apre il progetto in un dev container, e lo crea se manca |
| `dev --agent-in-container` | come `--container`, ma anche l'agente gira dentro il container |
| `dev -h` | aiuto |
| `dev-container` | scorciatoia per `dev --container` |
| `dev-opencode` | scorciatoia per `dev --agent opencode` |

Le opzioni si combinano: `dev-opencode --container`, `dev --container --agent-in-container`.
Se un progetto ha già un container avviato con `dev-container`, basta `dev`: lo trova da solo.

### Container

| Comando | Cosa fa |
| --- | --- |
| `dev-up [cartella]` | avvia il dev container del progetto. Se manca `.devcontainer/devcontainer.json` ne genera uno base. Salva l'id del container in `~/.cache/dev/<progetto>.json`. Di solito lo chiama `dev --container` |
| `dev-in [comando]` | esegue un comando nel container del progetto (senza comando apre `bash`). Se il progetto non ha un container, esegue il comando sul PC (senza comando apre `zsh`) |
| `dctl <sottocomando> ...` | la CLI `devcontainer` già impostata per Podman. Esempi: `dctl up --workspace-folder .`, `dctl exec --workspace-folder . bash` |
| `dev-personal-setup` | prepara o aggiorna `~/.local/share/dev-personal`, la cartella con Neovim, la configurazione e gli agenti che viene montata nei container |

### Chiudere

| Comando | Cosa fa |
| --- | --- |
| `dev-stop` | chiude tutte le sessioni tmux: principale, laterale e terminali. Vale per `dev`, `dev-opencode` e `dev-container` |
| `dev-stop -k` | come sopra, e ferma anche tutti i container avviati con `dev-up` |

`dev-stop` non ferma i container: il prossimo `dev` li ritrova accesi e parte subito.

### Script interni

Li usa `dev`, non serve lanciarli a mano:

- `dev-side`: costruisce il pannello laterale;
- `dev-side-width`: cambia la larghezza del pannello quando cambi scheda (log in `~/.cache/dev/side-width.log`);
- `dev-guard`: l'hook di protezione per Claude Code, vedi [più sotto](#protezione-dev-guard).

## Tasti

### Sessione principale (`~/.tmux.conf`, prefisso `Ctrl+b`)

| Tasto | Azione |
| --- | --- |
| `Ctrl+b \|` / `Ctrl+b -` | divide il pannello in verticale / orizzontale |
| `Ctrl+b h j k l` | sposta il cursore tra i pannelli |
| `Ctrl+b D` | podman-tui in una finestra a comparsa |
| `Ctrl+b r` | ricarica la configurazione |
| mouse | clic per scegliere il pannello, trascina per ridimensionare |

### Pannello laterale (`~/.tmux-side.conf`, senza prefisso)

| Tasto | Azione |
| --- | --- |
| `Alt+1` | agente (Claude o OpenCode) |
| `Alt+2` | lazygit |
| `Alt+3` | podman-tui |

### Terminali (`~/.tmux-terminals.conf`, prefisso `Ctrl+a`)

| Tasto | Azione |
| --- | --- |
| `Alt+n` | nuova scheda con `dev-in`: shell nel container se il progetto ne ha uno, altrimenti `zsh` sul PC |
| `Alt+←` / `Alt+→` | scheda precedente / successiva |
| `Alt+r` | rinomina la scheda |
| `Alt+x` | chiude la scheda (chiede conferma) |

Se il progetto ha un container ma è spento, `Alt+n` dà errore e la scheda si chiude subito: avvialo con `dev-container`.

### LazyVim

| Tasto | Azione |
| --- | --- |
| `Spazio` | menu dei comandi (aspetta un attimo e compare l'elenco) |
| `:Lazy` | gestione plugin. Dentro: `H` home, `U` aggiorna, `S` sincronizza, `q` chiude |
| `:lua Snacks.dashboard()` | torna alla schermata iniziale |

## Dev container: come funzionano

Su git **non** vanno né il container né l'immagine: va solo la **ricetta**.

- `.devcontainer/devcontainer.json` (nel repository del progetto) dice:
  - quale **immagine** di partenza usare, per esempio `mcr.microsoft.com/devcontainers/python:3.12`;
  - come personalizzarla: `features` (pacchetti pronti, per esempio Node o Go), `postCreateCommand` (comandi lanciati dopo la creazione), variabili, porte;
  - facoltativo: un `Dockerfile` accanto, per personalizzazioni più grandi.
- Sul PC di ognuno l'immagine viene scaricata (o costruita dal Dockerfile) e da lì nasce il **container**, con la cartella del progetto montata dentro.
- Il container si può buttare e ricreare quando vuoi: il codice sta nella cartella del progetto, sul PC.

Quindi ogni persona del team ottiene lo stesso ambiente (stesse versioni di linguaggi e strumenti), qualunque editor usi.

### Cosa aggiunge questo setup

`dev-up` usa la CLI ufficiale `devcontainer` con Podman:

1. cerca `.devcontainer/devcontainer.json` (o `.devcontainer.json`) nel progetto. Se c'è, usa **quello, senza modificarlo**. Se manca, ne genera uno base;
2. avvia il container con `devcontainer up` e in più monta `~/.local/share/dev-personal` in `/opt/personal`, passandolo da riga di comando: nel `devcontainer.json` non finisce niente;
3. LazyVim, Claude e OpenCode **non vengono installati nell'immagine**: il container usa le copie che stanno in `/opt/personal`.

Così il tuo editor funziona in qualunque dev container, anche in quelli di altri, e chi apre lo stesso progetto con VS Code non vede niente di tuo.

### Il devcontainer.json generato

```json
{
  "name": "nome-progetto",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "remoteUser": "vscode",
  "containerUser": "vscode",
  "updateRemoteUserUID": false,
  "runArgs": ["--userns=keep-id:uid=1000,gid=1000"],
  "postCreateCommand": "sudo apt-get update && sudo apt-get install -y ripgrep fd-find fzf build-essential unzip && sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd"
}
```

- `--userns=keep-id`: con Podman rootless fa coincidere l'utente `vscode` del container con il tuo utente sul PC, così i file creati nel container sono tuoi e non di un utente strano.
- `postCreateCommand`: installa ciò che serve a LazyVim (ricerca, compilatore per treesitter).

Adattalo al progetto: cambia `image`, aggiungi `features`, e committalo.

## Creare un progetto con il dev container

```bash
mkdir -p ~/progetti/mio-progetto && cd ~/progetti/mio-progetto && git init
dev-container
```

Al primo avvio, in automatico:

1. viene generato `.devcontainer/devcontainer.json`;
2. se manca, viene preparato `~/.local/share/dev-personal`;
3. viene scaricata l'immagine e avviato il container (ci vuole qualche minuto la prima volta);
4. si apre il solito schermo: LazyVim e terminali dentro il container, Claude e lazygit sul PC;
5. nel progetto viene scritto `.claude/settings.local.json` con l'hook `dev-guard`.

Poi:

- modifica `devcontainer.json` per il progetto. Per esempio, per Python:
  ```json
  "image": "mcr.microsoft.com/devcontainers/python:3.12"
  ```
- per applicare una modifica della ricetta bisogna ricreare il container:
  ```bash
  dev-stop -k
  podman ps -a              # trova l'id del container del progetto
  podman rm -f <id>
  dev-container
  ```
- committa `.devcontainer/`. Aggiungi `.claude/settings.local.json` al `.gitignore`: è tuo, non del progetto.

Tutti i giorni:

```bash
cd ~/progetti/mio-progetto
dev                  # trova da solo il container
dev-in npm test      # un comando nel container, da qualunque terminale
dev-stop             # chiude, il container resta acceso
dev-stop -k          # chiude e ferma il container
```

## Aprire il dev container di qualcun altro

```bash
git clone <repo> && cd <repo>
dev-container
```

`dev-up` usa il loro `devcontainer.json` così com'è. Cosa può andare storto, dal più probabile:

1. **Permessi dei file**. Le loro ricette di solito sono pensate per Docker e non hanno `--userns=keep-id`. Con Podman rootless l'utente del container non riesce a scrivere nel progetto, o crea file con un proprietario strano. Soluzione: aggiungi nella tua copia locale `"runArgs": ["--userns=keep-id"]` e **non committarlo**.
2. **Mancano gli strumenti per LazyVim**. Il loro `postCreateCommand` non installa ripgrep, fd o un compilatore: LazyVim parte, ma la ricerca e treesitter funzionano male. Soluzione: `dev-in sudo apt-get install -y ripgrep fd-find build-essential`.
3. **Immagini Alpine o senza bash**. `dev-in` usa `bash`, e `nvim`, `claude` e `opencode` copiati dal PC hanno bisogno di glibc: su Alpine non partono.
4. **Ricette con docker-compose o con la feature Docker-in-Docker**. Serve `docker-compose` installato, e alcune feature pensate per Docker non funzionano con Podman.

Claude locale, lazygit e git restano sul PC, quindi questi problemi non li toccano.

## Dove gira cosa

| Programma | Senza container | `--container` | `--agent-in-container` |
| --- | --- | --- | --- |
| LazyVim | PC | container | container |
| Terminali | PC | container | container |
| Agente (Claude o OpenCode) | PC | **PC** | container |
| lazygit, git, podman-tui | PC | PC | PC |

Con `--container` l'agente è **il tuo Claude locale**: stesso login, stessa configurazione `~/.claude`. Git gira sempre sul PC, così le chiavi SSH e le credenziali di GitHub non entrano mai nel container.

Con `--agent-in-container` l'agente è una copia separata che usa `/opt/personal/claude` come configurazione. Il login va fatto una volta dentro il container: `dev-in claude` (oppure `dev-in opencode`).

## Protezione dev-guard

Con il progetto nel container e Claude Code sul PC, Claude potrebbe lanciare i comandi sul PC invece che nel container (per esempio installare pacchetti sul PC). Per evitarlo `dev` aggiunge a `.claude/settings.local.json` del progetto:

- un hook `PreToolUse` che passa ogni comando Bash a `dev-guard`;
- il permesso `Bash(dev-in:*)`.

`dev-guard` lascia passare solo `dev-in ...` e comandi di sola lettura: `cd git ls cat rg fd pwd echo head tail wc grep tree stat file diff which true`. Tutto il resto viene bloccato, con un messaggio che dice a Claude di rifare il comando con `dev-in`. Se l'hook si rompe, blocca per sicurezza.

Limiti:

- protegge dagli errori, non da un attacco fatto apposta;
- non controlla gli strumenti Edit e Write: Claude scrive i file direttamente sul PC (sono gli stessi file del container, perché la cartella è montata), e potrebbe scrivere anche fuori dal progetto;
- vale solo per Claude Code. Con OpenCode sul PC non c'è un equivalente: usa `--agent-in-container`.

## Configurazione personale nel container

`dev-personal-setup` copia in `~/.local/share/dev-personal`:

| Cosa | Da | Nel container |
| --- | --- | --- |
| Neovim (programma e runtime) | la cartella del tarball ufficiale | `/opt/personal/nvim` |
| configurazione di LazyVim | `~/.config/nvim` | `/opt/personal/config/nvim` |
| `claude`, `opencode` | il programma installato sul PC | `/opt/personal/bin` |
| regole e skill di Claude | `~/.claude/CLAUDE.md`, `skills`, `commands`, `agents` | `/opt/personal/claude` |

Nel container `dev-in` imposta `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_STATE_HOME`, `XDG_CACHE_HOME` e `CLAUDE_CONFIG_DIR` dentro `/opt/personal`. I plugin di LazyVim scaricati lì sono quindi condivisi tra tutti i container.

È una **copia**: dopo aver cambiato la configurazione di LazyVim o aggiornato Claude sul PC, rilancia `dev-personal-setup`.

Login e chiavi API (`~/.claude/.credentials.json` e simili) non vengono mai copiati.

## Spostare tutto su un PC nuovo: dev-env.sh

`dev-env.sh` porta tutto l'ambiente da un PC a un altro (Debian, Ubuntu, Mint).

Sul PC di partenza:

```bash
./dev-env.sh export                     # crea ~/dev-env-DATA.tar.gz
./dev-env.sh export --claude-settings   # include anche ~/.claude/settings.json (controllalo prima)
```

L'archivio contiene le configurazioni (tmux, script `dev*`, Neovim, lazygit, regole e skill di Claude), le impostazioni di Git (nome, email, alias) e un inventario dei programmi installati. Non contiene chiavi SSH, token né credenziali. Non pubblicarlo comunque: sono le tue configurazioni.

Sul PC nuovo:

```bash
tar xzf dev-env-DATA.tar.gz && cd dev-env
./dev-env.sh install                         # strumenti base, Neovim, LazyVim, lazygit, Claude, font, oh-my-zsh
./dev-env.sh install --containers            # in più: Podman, docker-compose, mise, Node, CLI devcontainer, podman-tui
./dev-env.sh install --containers --flutter  # in più: Flutter
```

Alla fine stampa i passi da fare a mano: `chsh` per zsh, scegliere il font nel terminale, `gh auth login`, login di Claude, chiavi SSH.

## Problemi comuni

| Problema | Causa e soluzione |
| --- | --- |
| `dev-up: devcontainer is not installed` | `npm i -g @devcontainers/cli` |
| `dev-in: the dev container is not running` | il container è spento: `dev-container` |
| `nvim comes from the system packages` | serve il Neovim ufficiale in `/opt`, quello di apt non si può copiare nel container |
| nel container non posso scrivere i file del progetto | manca `--userns=keep-id` nella ricetta, vedi [sopra](#aprire-il-dev-container-di-qualcun-altro) |
| ho cambiato `devcontainer.json` ma non cambia niente | il container vecchio è ancora lì: `podman rm -f <id>` e poi `dev-container` |
| il pannello laterale ha la larghezza sbagliata | guarda `~/.cache/dev/side-width.log` |
| Claude mi dice che un comando è bloccato | è `dev-guard`: il comando va fatto con `dev-in`. Per toglierlo, cancella l'hook da `.claude/settings.local.json` |
| LazyVim nel container non ha le mie ultime modifiche | `dev-personal-setup` |
| `Alt+n` non apre la shell nel container | chiudi e riapri le sessioni (`dev-stop` e poi `dev`) per caricare la nuova configurazione |

## Disinstallare o tornare indietro

Le versioni precedenti degli script sostituiti stanno in `~/.dev-variants-backup-DATA/`. Per tornare indietro:

```bash
cp ~/.dev-variants-backup-DATA/* ~/.local/bin/
```

Per togliere tutto:

```bash
cd ~/.local/bin && rm -f dctl dev-container dev-guard dev-in dev-opencode dev-personal-setup dev-up
sed -i '/# >>> dev-variants >>>/,/# <<< dev-variants <<</d' ~/.tmux-terminals.conf
rm -rf ~/.local/share/dev-personal ~/.cache/dev
```

`dev`, `dev-side`, `dev-side-width` e `dev-stop` c'erano anche prima: rimettili dal backup invece di cancellarli.

## Sicurezza

- Le credenziali stanno fuori dal progetto, quindi non finiscono nei commit. Git gira sul PC.
- Non scrivere chiavi in `devcontainer.json`: è un file che si committa.
- Il codice nel container può leggere tutto quello che c'è in `~/.local/share/dev-personal`: non metterci altro e non montare altre cartelle del PC.
- Per i modelli esterni usa chiavi API dedicate, con un tetto di spesa.
- `dev-guard` riduce gli errori dell'agente, ma non è un confine di sicurezza.

## Test

```bash
python3 -m unittest discover -s tests   # dev-guard: 21 test
bash tests/test_scripts.sh              # script con tmux vero e programmi finti: 64 controlli
```

`test_scripts.sh` lavora in una home temporanea: non tocca la tua configurazione.

## Cosa non è ancora provato

I test usano tmux vero, ma Podman, `devcontainer`, Neovim, Claude e OpenCode simulati. Da verificare al primo uso reale:

- `devcontainer up` con Podman rootless;
- i permessi della cartella montata;
- `claude` e `opencode` copiati che partono nel container;
- il login di OpenCode con Claude.
