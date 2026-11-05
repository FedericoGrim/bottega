# Bottega

Il mio ambiente di sviluppo da terminale: un comando `dev` che apre in tmux LazyVim, l'agente AI (Claude Code o OpenCode), lazygit, un pannello per i container (podman-tui o lazydocker) e i terminali, sul PC o dentro un dev container con Podman o Docker.

Quattro ambienti, un comando ciascuno:

| Comando | Progetto | Agente |
| --- | --- | --- |
| `dev` | sul PC | Claude Code |
| `dev-o` | sul PC | OpenCode |
| `dev-c-c` | in un dev container | Claude Code (sul PC) |
| `dev-c-o` | in un dev container | OpenCode (sul PC) |

`dev --help` mostra l'elenco di tutti i comandi.

- [Come è fatto lo schermo](#come-è-fatto-lo-schermo)
- [Installazione](#installazione)
- [Le scelte dell'installer](#le-scelte-dellinstaller)
- [Comandi](#comandi)
- [Tasti](#tasti)
- [Guida rapida: Ctrl+b g](#guida-rapida-ctrlb-g)
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
│                              │ 3 podman o  │
│                              │   docker    │
│                              │             │
├──────────────────────────────┤  (pannello  │
│  terminali (Alt+n nuovo)     │  laterale)  │
└──────────────────────────────┴─────────────┘
```

- **Editor**: LazyVim.
- **Terminali** in basso: una sessione tmux a parte (`-L terminals`) con le sue schede.
- **Pannello laterale** a destra: una terza sessione tmux (`-L side`) con tre schede: agente, lazygit e il pannello dei container scelto (podman-tui o lazydocker; la scheda si chiama `podman` o `docker` come il motore). Se il pannello non è installato, al suo posto gira `watch podman ps -a` (o `docker ps -a`). La larghezza del pannello cambia con la scheda: agente 30% (OpenCode 35%), lazygit 40%, container 55%.

Se la sessione esiste già, `dev` ci rientra invece di crearne una nuova.

## Installazione

```bash
git clone https://github.com/FedericoGrim/bottega.git
cd bottega
./install.sh
```

`install.sh` prima fa alcune domande (vedi [sotto](#le-scelte-dellinstaller)), poi:

1. copia gli script di `bin/` in `~/.local/bin`. Se c'è già un file diverso con lo stesso nome, prima lo salva in `~/.bottega-backup-DATA/`;
2. copia le configurazioni di tmux da `tmux/` in `~/.tmux.conf`, `~/.tmux-side.conf` e `~/.tmux-terminals.conf`, **solo se mancano**: quelle che hai già restano come sono;
3. toglie i vecchi nomi `dev-container` e `dev-opencode` (dopo averli messi nel backup);
4. aggiunge a `~/.tmux-terminals.conf` un blocco che fa aprire `dev-in` con `Alt+n`;
5. aggiunge a `~/.tmux.conf` un blocco che apre la [guida rapida](#guida-rapida-ctrlb-g) con `Ctrl+b g`, e copia gli argomenti di `cheatsheet/` in `~/.local/share/bottega/cheatsheet/`;
6. se hai scelto zsh, installa oh-my-zsh e i plugin;
7. salva le scelte in `~/.config/bottega/config` (se trova la vecchia `~/.config/dev-variants/config`, la sposta lì);
8. controlla solo i programmi che servono per le tue scelte e, per quelli che mancano, stampa il comando per installarli. Non installa niente da solo, tranne zsh.

Si può rilanciare quando vuoi, per esempio dopo un `git pull` o per cambiare le scelte: propone come risposta predefinita quelle dell'ultima volta, e il blocco in `~/.tmux-terminals.conf` non viene duplicato.

## Le scelte dell'installer

| Domanda | Risposte | Cosa cambia |
| --- | --- | --- |
| Ambienti | uno o più tra `dev`, `dev-o`, `dev-c-c`, `dev-c-o` | quali programmi vengono controllati: Claude per `dev` e `dev-c-c`, OpenCode per `dev-o` e `dev-c-o`, motore e CLI `devcontainer` per `dev-c-*`. I comandi vengono installati comunque tutti |
| Motore dei container (solo con `dev-c-*`) | `podman` o `docker` | quale programma usano `dev-up`, `dev-in`, `dctl` e `dev-stop`, e com'è fatto il `devcontainer.json` generato |
| Pannello dei container (solo con Podman) | `podman-tui` o `lazydocker` | cosa gira nella scheda 3 del pannello laterale. Con Docker è sempre lazydocker, perché podman-tui funziona solo con Podman |
| Shell delle sessioni dev | `zsh` o `keep` | la shell dei pannelli aperti da `dev` sul PC. **La shell di sistema non cambia**: fuori da `dev` resta la tua. Con `zsh` l'installer installa oh-my-zsh e i plugin `git zsh-autosuggestions fzf fast-syntax-highlighting`; un `.zshrc` già presente non viene sostituito, cambia solo la riga `plugins=` |

Dentro il container la shell è sempre `bash` dell'immagine, qualunque sia la scelta.

Senza terminale (per esempio in uno script) o con `--yes` non fa domande e usa le scelte precedenti, o quelle predefinite: tutti gli ambienti, Podman, podman-tui, shell `keep`. Le scelte si possono dare anche da riga di comando:

```bash
./install.sh --envs dev,dev-c-c --engine docker --shell zsh
./install.sh --yes --envs all --engine podman --panel lazydocker --shell keep
./install.sh --help
```

Il file `~/.config/bottega/config` si può anche modificare a mano. Ogni valore si può cambiare per un solo comando con una variabile d'ambiente con lo stesso nome, per esempio `DEV_ENGINE=docker dev-c-c`.

### Cosa serve

| Programma | Serve per | Come si installa |
| --- | --- | --- |
| tmux 3.2 o più recente | tutto | `sudo apt install tmux` |
| jq, python3 | tutto | `sudo apt install jq python3` |
| Neovim ufficiale + LazyVim | editor | tarball in `/opt` (vedi `dev-env.sh`). Quello dei pacchetti di sistema non va bene per il container |
| lazygit | pannello laterale | vedi `dev-env.sh` |
| Claude Code | agente | `curl -fsSL https://claude.ai/install.sh \| bash` |
| podman 4.3 o più recente, oppure Docker | container | `sudo apt install podman` / `sudo apt install docker.io && sudo usermod -aG docker $USER` |
| CLI `devcontainer` | container | `npm i -g @devcontainers/cli` |
| podman-tui | pannello laterale con Podman | `dev-env.sh install --containers` |
| lazydocker | pannello laterale con Docker (o con Podman, se lo scegli) | [script ufficiale](https://github.com/jesseduffield/lazydocker#installation) |
| OpenCode | `dev-o`, `dev-c-o` | `npm i -g opencode-ai` |
| docker-compose | solo i dev container basati su compose | vedi `dev-env.sh` |
| bat, eza, delta, direnv, uv, starship | `cat` e `ls` migliori, diff di git leggibili, ambiente per cartella, progetti Python, prompt di zsh con branch e stato git | `dev-env.sh install` (li gestisce mise) |
| Java, Maven, Python, .NET, Go, Node, Rust, pnpm | i linguaggi che LazyVim sa usare | `dev-env.sh install --languages` |

`~/.local/bin` deve essere nel `PATH`.

## Comandi

### Avviare l'ambiente

| Comando | Cosa fa |
| --- | --- |
| `dev [cartella]` | apre l'ambiente per la cartella indicata (o quella corrente). Agente predefinito: Claude Code |
| `dev --agent opencode` | come sopra, con OpenCode al posto di Claude |
| `dev --container` | apre il progetto in un dev container, e lo crea se manca |
| `dev --agent-in-container` | come `--container`, ma anche l'agente gira dentro il container |
| `dev -h`, `dev --help` | opzioni ed elenco di tutti i comandi |
| `dev-o` | scorciatoia per `dev --agent opencode` |
| `dev-c-c` | scorciatoia per `dev --container` |
| `dev-c-o` | scorciatoia per `dev --container --agent opencode` |

Le opzioni si combinano: `dev-c-o --agent-in-container`, `dev-c-c ~/progetti/altro`.
Se un progetto ha già un container avviato con `dev-c-c` o `dev-c-o`, basta `dev`: lo trova da solo.

### Container

| Comando | Cosa fa |
| --- | --- |
| `dev-up [cartella]` | avvia il dev container del progetto. Se manca `.devcontainer/devcontainer.json` ne genera uno base. Salva l'id del container in `~/.cache/dev/<progetto>.json`. Di solito lo chiama `dev --container` |
| `dev-in [comando]` | esegue un comando nel container del progetto (senza comando apre `bash`). Se il progetto non ha un container, esegue il comando sul PC (senza comando apre la shell scelta) |
| `dctl <sottocomando> ...` | la CLI `devcontainer` già impostata per il motore scelto. Esempi: `dctl up --workspace-folder .`, `dctl exec --workspace-folder . bash` |
| `dev-personal-setup` | prepara o aggiorna `~/.local/share/dev-personal`, la cartella con Neovim, la configurazione e gli agenti che viene montata nei container |

### Guida

| Comando | Cosa fa |
| --- | --- |
| `dev-docs` | apre la [guida rapida](#guida-rapida-ctrlb-g) nel terminale attuale (di solito la apri con `Ctrl+b g`) |

### Chiudere

| Comando | Cosa fa |
| --- | --- |
| `dev-stop` | chiude tutte le sessioni tmux: principale, laterale e terminali. Vale per tutti e quattro gli ambienti |
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
| `Ctrl+b g` | apre la [guida rapida](#guida-rapida-ctrlb-g) in una finestra a comparsa |
| `Ctrl+b r` | ricarica la configurazione |
| mouse | clic per scegliere il pannello, trascina per ridimensionare |

### Pannello laterale (`~/.tmux-side.conf`, senza prefisso)

| Tasto | Azione |
| --- | --- |
| `Alt+1` | agente (Claude o OpenCode) |
| `Alt+2` | lazygit |
| `Alt+3` | pannello dei container (podman-tui o lazydocker) |

### Terminali (`~/.tmux-terminals.conf`, prefisso `Ctrl+a`)

| Tasto | Azione |
| --- | --- |
| `Alt+n` | nuova scheda con `dev-in`: shell nel container se il progetto ne ha uno, altrimenti la shell scelta sul PC |
| `Alt+←` / `Alt+→` | scheda precedente / successiva |
| `Alt+r` | rinomina la scheda |
| `Alt+x` | chiude la scheda (chiede conferma) |

Se il progetto ha un container ma è spento, `Alt+n` dà errore e la scheda si chiude subito: avvialo con `dev-c-c` o `dev-c-o`.

### LazyVim

| Tasto | Azione |
| --- | --- |
| `Spazio` | menu dei comandi (aspetta un attimo e compare l'elenco) |
| `:Lazy` | gestione plugin. Dentro: `H` home, `U` aggiorna, `S` sincronizza, `q` chiude |
| `:lua Snacks.dashboard()` | torna alla schermata iniziale |
| `:LazyExtras` | attiva o disattiva i linguaggi e gli strumenti (`x` sulla riga) |
| `Spazio c m` | Mason: server, formatter e debugger installati |

#### Linguaggi e strumenti già attivi

Gli extras di LazyVim attivi sono in `nvim/lazyvim.json`, nel repository, insieme al resto della configurazione di Neovim (`nvim/lua/`). `dev-env.sh install` la copia in `~/.config/nvim` se lì non c'è già un `init.lua`; l'archivio dell'export, se c'è, ha la precedenza. `lazy-lock.json` non è versionato: i plugin restano sempre all'ultima versione.

Gli extras attivi:

| Linguaggio | Server | Debug | Test |
| --- | --- | --- | --- |
| Python | pyright, ruff | debugpy | neotest-python |
| Java | jdtls | java-debug-adapter | neotest-java |
| Go | gopls | delve | neotest-golang |
| Rust | rust-analyzer | codelldb | rustaceanvim |
| C# | Roslyn (non OmniSharp) | netcoredbg | neotest-vstest |
| Node e TypeScript | vtsls, eslint | js-debug-adapter | jest e vitest |

In più: JSON, YAML, TOML, Markdown, Docker, Git, formattazione con prettier, refactoring e rinomina con anteprima, GitHub con Octo.

| Tasti | Azione |
| --- | --- |
| `Spazio d b` | punto di interruzione |
| `Spazio d c` | avvia o continua il debug |
| `Spazio d i / d O / d o` | entra nella funzione / passa oltre / esce |
| `Spazio d u` | pannello del debug |
| `Spazio t r` | esegue il test più vicino |
| `Spazio t t` | esegue i test del file |
| `Spazio t T` | esegue tutti i test |
| `Spazio t s` | riepilogo dei test |
| `Spazio t d` | debug del test più vicino |
| `Spazio r f / r x / r i` | estrae una funzione / una variabile, o riporta nel codice una variabile |
| `Spazio c r` | rinomina con anteprima in diretta |
| `Spazio g i / g p` | elenco delle issue / delle PR di GitHub (Octo) |

Per C# serve un file `.sln` o `.csproj` nella cartella: Roslyn analizza l'intera soluzione, quindi la prima apertura è lenta.

## Guida rapida: Ctrl+b g

`Ctrl+b g` apre, da qualsiasi pannello, una finestra a comparsa grande quasi come lo schermo con i comandi e i tasti di tutti gli strumenti: comando a sinistra, cosa fa a destra.

| Tasto | Azione |
| --- | --- |
| scrivi | filtra le righe mentre scrivi: basta un pezzo del comando o della descrizione (`rebase`, `annulla`) |
| `Tab` / `Shift+Tab` | argomento successivo / precedente; `Tutti` cerca in tutti gli argomenti |
| `↑` / `↓` | scorre le righe |
| `Invio` | copia il comando negli appunti del PC e chiude: lo incolli con `Ctrl+Shift+V` |
| `Esc` | chiude |

Gli argomenti sono i file Markdown di [`cheatsheet/`](cheatsheet), uno per argomento: Git, GitHub (con i nomi di branch, commit e PR), lazygit, LazyVim, Podman, DevContainer, Claude Code, tmux e Bottega, Terminale, Flutter, .NET, Spring Boot, Java, Node.js, Python, Go, Rust.

Per aggiungere o modificare un argomento:

1. crea o modifica un file in `cheatsheet/`: un titolo `# Argomento`, poi sezioni `## Sezione` con tabelle a due colonne `| comando | cosa fa |`. Il testo fuori dalle tabelle viene ignorato; un `|` dentro una cella si scrive `\|`;
2. rilancia `./install.sh`.

Per gli appunti serve `xclip` su X11 o `wl-copy` (`wl-clipboard`) su Wayland: `install.sh` ti dice se manca. Senza, il comando va negli appunti di tmux, e da lì negli appunti del PC solo se il terminale supporta OSC 52.

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

`dev-up` usa la CLI ufficiale `devcontainer` con il motore scelto (Podman o Docker):

1. cerca `.devcontainer/devcontainer.json` (o `.devcontainer.json`) nel progetto. Se c'è, usa **quello, senza modificarlo**. Se manca, ne genera uno base;
2. avvia il container con `devcontainer up` e in più monta `~/.local/share/dev-personal` in `/opt/personal`, passandolo da riga di comando: nel `devcontainer.json` non finisce niente;
3. LazyVim, Claude e OpenCode **non vengono installati nell'immagine**: il container usa le copie che stanno in `/opt/personal`.

Così il tuo editor funziona in qualunque dev container, anche in quelli di altri, e chi apre lo stesso progetto con VS Code non vede niente di tuo.

### Il devcontainer.json generato

Con Podman:

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

Con Docker al posto di `updateRemoteUserUID: false` e `runArgs` c'è `"updateRemoteUserUID": true`: è la CLI `devcontainer` che allinea l'utente `vscode` al tuo.

- `--userns=keep-id`: con Podman rootless fa coincidere l'utente `vscode` del container con il tuo utente sul PC, così i file creati nel container sono tuoi e non di un utente strano.
- `postCreateCommand`: installa ciò che serve a LazyVim (ricerca, compilatore per treesitter).

Adattalo al progetto: cambia `image`, aggiungi `features`, e committalo.

## Creare un progetto con il dev container

```bash
mkdir -p ~/progetti/mio-progetto && cd ~/progetti/mio-progetto && git init
dev-c-c
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
  podman ps -a              # o docker ps -a: trova l'id del container del progetto
  podman rm -f <id>         # o docker rm -f <id>
  dev-c-c
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
dev-c-c
```

`dev-up` usa il loro `devcontainer.json` così com'è. Cosa può andare storto, dal più probabile:

1. **Permessi dei file**. Le loro ricette di solito sono pensate per Docker e non hanno `--userns=keep-id`. Con Podman rootless l'utente del container non riesce a scrivere nel progetto, o crea file con un proprietario strano. Soluzione: aggiungi nella tua copia locale `"runArgs": ["--userns=keep-id"]` e **non committarlo**.
2. **Mancano gli strumenti per LazyVim**. Il loro `postCreateCommand` non installa ripgrep, fd o un compilatore: LazyVim parte, ma la ricerca e treesitter funzionano male. Soluzione: `dev-in sudo apt-get install -y ripgrep fd-find build-essential`.
3. **Immagini Alpine o senza bash**. `dev-in` usa `bash`, e `nvim`, `claude` e `opencode` copiati dal PC hanno bisogno di glibc: su Alpine non partono.
4. **Ricette con docker-compose o con la feature Docker-in-Docker**. Serve `docker-compose` installato, e alcune feature pensate per Docker non funzionano con Podman.

Claude locale, lazygit e git restano sul PC, quindi questi problemi non li toccano.

## Dove gira cosa

| Programma | `dev`, `dev-o` | `dev-c-c`, `dev-c-o` | con `--agent-in-container` |
| --- | --- | --- | --- |
| LazyVim | PC | container | container |
| Terminali | PC | container | container |
| Agente (Claude o OpenCode) | PC | **PC** | container |
| lazygit, git, pannello dei container | PC | PC | PC |

Con `dev-c-c` e `dev-c-o` l'agente è **quello installato sul PC**: stesso login, stessa configurazione `~/.claude`. Git gira sempre sul PC, così le chiavi SSH e le credenziali di GitHub non entrano mai nel container.

Con `--agent-in-container` l'agente è una copia separata che usa `/opt/personal/claude` come configurazione. Il login va fatto una volta dentro il container: `dev-in claude` (oppure `dev-in opencode`).

## Protezione dev-guard

Con il progetto nel container e Claude Code sul PC, Claude potrebbe lanciare i comandi sul PC invece che nel container (per esempio installare pacchetti sul PC). Per evitarlo `dev` aggiunge a `.claude/settings.local.json` del progetto:

- un hook `PreToolUse` che passa ogni comando Bash a `dev-guard`;
- il permesso `Bash(dev-in:*)`.

`dev-guard` lascia passare solo `dev-in ...` e comandi di sola lettura: `cd git ls cat rg fd pwd echo head tail wc grep tree stat file diff which true`. Tutto il resto viene bloccato, con un messaggio che dice a Claude di rifare il comando con `dev-in`. Se l'hook si rompe, blocca per sicurezza.

Limiti:

- protegge dagli errori, non da un attacco fatto apposta;
- non controlla gli strumenti Edit e Write: Claude scrive i file direttamente sul PC (sono gli stessi file del container, perché la cartella è montata), e potrebbe scrivere anche fuori dal progetto;
- vale solo per Claude Code. **Con `dev-c-o` OpenCode gira sul PC senza protezione**: può eseguire comandi sul PC invece che nel container. Se vuoi evitarlo usa `dev-c-o --agent-in-container`.

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

L'archivio contiene le configurazioni (tmux, script `dev*`, Neovim, lazygit, la sezione `[tools]` di mise, starship, regole e skill di Claude), le impostazioni di Git (nome, email, alias, delta e stile dei conflitti) e un inventario dei programmi installati con le loro versioni. Non contiene chiavi SSH, token né credenziali. Non pubblicarlo comunque: sono le tue configurazioni.

Sul PC nuovo:

```bash
tar xzf dev-env-DATA.tar.gz && cd dev-env
./dev-env.sh install                         # strumenti base, Neovim, LazyVim, lazygit, Claude, font, oh-my-zsh, bat, eza, delta, direnv, uv, starship
./dev-env.sh install --languages             # in più: Java, Maven, Python, .NET, Go, Node, Rust, pnpm
./dev-env.sh install --containers            # in più: Podman, docker-compose, mise, Node, CLI devcontainer, podman-tui
./dev-env.sh install --containers --flutter  # in più: Flutter
```

Le opzioni si possono combinare. Cosa fa, in ordine:

1. installa i pacchetti di sistema, Neovim ufficiale, lazygit, Claude Code, il font e oh-my-zsh;
2. rimette al loro posto le configurazioni dell'archivio (le versioni diverse già presenti vanno in un backup);
   poi, se `~/.config/nvim/init.lua` non esiste, copia la configurazione di `nvim/` del repository, e solo in mancanza di quella clona il LazyVim starter;
3. scrive in `~/.zshrc`, tra i marcatori `# >>> dev-env >>>` e `# <<< dev-env <<<`, il `PATH`, zoxide, mise, direnv, cargo e il prompt starship (il blocco si rigenera a ogni esecuzione);
4. installa con mise bat, eza, delta, direnv, uv e starship, più tutto quello che c'è nel `config.toml` di mise dell'archivio;
5. applica le impostazioni di Git. Se delta non è installato salta `core.pager` e `interactive.diffFilter`, così git non smette di mostrare l'output;
6. con `--languages`: JDK 21, Maven e Python con apt, `dotnet-sdk-10.0` con apt (se il sistema non lo ha, stampa il link per installarlo a mano), Go, Node LTS e pnpm con mise, Rust con `rustup`. Se un passo dei linguaggi fallisce, l'installer lo segnala e va avanti;
7. scarica i plugin di LazyVim e poi, **aspettando che finiscano**, installa i parser treesitter e i pacchetti di Mason (server, debugger e formatter).

La parte di Neovim può richiedere diversi minuti. Se un pacchetto non si installa, l'installer lo segnala e continua: lo recuperi con `:Mason`.

Alla fine stampa i passi da fare a mano: `chsh` per zsh, scegliere il font nel terminale, `gh auth login`, login di Claude, chiavi SSH.

## Problemi comuni

| Problema | Causa e soluzione |
| --- | --- |
| `dev-up: devcontainer is not installed` | `npm i -g @devcontainers/cli` |
| `dev-in: the dev container is not running` | il container è spento: `dev-c-c` o `dev-c-o` |
| `nvim comes from the system packages` | serve il Neovim ufficiale in `/opt`, quello di apt non si può copiare nel container |
| nel container non posso scrivere i file del progetto | manca `--userns=keep-id` nella ricetta, vedi [sopra](#aprire-il-dev-container-di-qualcun-altro) |
| ho cambiato `devcontainer.json` ma non cambia niente | il container vecchio è ancora lì: `podman rm -f <id>` (o `docker rm -f <id>`) e poi `dev-c-c` |
| il pannello laterale ha la larghezza sbagliata | guarda `~/.cache/dev/side-width.log` |
| Claude mi dice che un comando è bloccato | è `dev-guard`: il comando va fatto con `dev-in`. Per toglierlo, cancella l'hook da `.claude/settings.local.json` |
| LazyVim nel container non ha le mie ultime modifiche | `dev-personal-setup` |
| `roslyn` non si installa da `:Mason` (errore 404 sul download) | il registry `Crashdummyy/mason-registry` punta a una release che non esiste ancora. Installa l'ultima esistente: `:MasonInstall roslyn@5.14.0-1.26552.12` (l'installer lo fa da solo) |
| `cargo`, `uv` o `pnpm` non si trovano | apri una shell nuova, oppure `source ~/.cargo/env`; controlla che `~/.local/bin` sia nel `PATH` |
| `git diff` non mostra più niente | `delta` non è installato ma `core.pager` lo richiede: `mise use -g delta`, oppure `git config --global --unset core.pager` |
| `dev-up: docker is not installed` (o `podman`) | il motore scelto non c'è: installalo, o rilancia `./install.sh` e scegli l'altro |
| `dev-container: command not found` | i vecchi nomi sono stati tolti: usa `dev-c-c` e `dev-o`/`dev-c-o` |
| `Alt+n` non apre la shell nel container | chiudi e riapri le sessioni (`dev-stop` e poi `dev`) per caricare la nuova configurazione |

## Disinstallare o tornare indietro

Le versioni precedenti degli script sostituiti stanno in `~/.bottega-backup-DATA/`. Per tornare indietro:

```bash
cp ~/.bottega-backup-DATA/* ~/.local/bin/
```

Per togliere tutto:

```bash
cd ~/.local/bin && rm -f dctl dev-o dev-c-c dev-c-o dev-guard dev-in dev-personal-setup dev-up
sed -i '/# >>> bottega >>>/,/# <<< bottega <<</d' ~/.tmux-terminals.conf
rm -rf ~/.local/share/dev-personal ~/.cache/dev ~/.config/bottega
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
python3 -m unittest discover -s tests   # dev-guard e dev-docs: 38 test
bash tests/test_scripts.sh              # script con tmux vero e programmi finti: 123 controlli
bash tests/test_dev_env.sh              # installer ed export di dev-env.sh, con apt, mise e nvim finti: 100 controlli
```

`test_scripts.sh` e `test_dev_env.sh` lavorano in una home temporanea: non toccano la tua configurazione.

## Cosa non è ancora provato

I test usano tmux vero, ma Podman, Docker, `devcontainer`, Neovim, Claude, OpenCode, podman-tui e lazydocker simulati. Da verificare al primo uso reale:

- `devcontainer up` con Podman rootless e con Docker;
- lazydocker con il socket di Podman;
- i permessi della cartella montata;
- `claude` e `opencode` copiati che partono nel container;
- il login di OpenCode con Claude.
