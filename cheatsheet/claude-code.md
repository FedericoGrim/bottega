# Claude Code

## Avviare e riprendere

| Comando | Cosa fa |
| --- | --- |
| `claude` | apre una nuova sessione nella cartella attuale |
| `claude "spiegami questo progetto"` | apre la sessione e invia subito la richiesta |
| `claude -c` | riprende l'ultima conversazione in questa cartella |
| `claude -r` | sceglie da un elenco quale conversazione riprendere |
| `claude -p "domanda"` | risponde e termina, senza sessione (utile negli script) |
| `claude --version` | mostra la versione installata |
| `claude update` | aggiorna a mano (l'installer nativo si aggiorna da solo) |
| `claude doctor` | controlla l'installazione senza aprire una sessione |

## Prefissi del messaggio

| Prefisso | Cosa fa |
| --- | --- |
| `/` | elenco dei comandi e delle skill |
| `@file` | indica un file da leggere, con completamento (@src/main.py) |
| `! comando` | esegue un comando di shell; l'output entra nella conversazione (! npm test) |
| `?` | su prompt vuoto: aiuto sulle scorciatoie |

## Tasti

| Tasto | Cosa fa |
| --- | --- |
| `Esc` | ferma Claude mentre lavora, tenendo quello che ha fatto; chiude un menu |
| `Esc Esc` | cancella il testo scritto; a prompt vuoto apre il rewind |
| `Shift+Tab` | cambia modalità di permesso |
| `Freccia su` | richiama i messaggi precedenti |
| `Ctrl+r` | cerca nei messaggi che hai già scritto |
| `Ctrl+g` | scrive il messaggio in Neovim: comodo per richieste lunghe |
| `\ + Invio oppure Ctrl+j` | va a capo senza inviare |
| `Ctrl+v` | incolla un'immagine dagli appunti |
| `Ctrl+o` | dettagli di cosa ha fatto Claude (strumenti, comandi) |
| `Ctrl+t` | mostra o nasconde la lista di attività |
| `Ctrl+s` | mette da parte il messaggio e lo riprende dopo |
| `Alt+p` | cambia modello senza perdere il messaggio |
| `Ctrl+b Ctrl+b` | manda in background un comando lungo (due volte per via di tmux) |
| `Ctrl+c` | cancella il messaggio; premuto di nuovo esce |

## Comandi slash

| Comando | Cosa fa |
| --- | --- |
| `/init` | crea un CLAUDE.md iniziale leggendo il progetto |
| `/memory` | modifica i CLAUDE.md e la memoria automatica |
| `/permissions` | regole su cosa può fare senza chiedere |
| `/config` | impostazioni: tema, modello, editor vim |
| `/plan descrizione` | entra in plan mode partendo da quel compito |
| `/model` | cambia modello |
| `/effort` | cambia quanto ragiona |
| `/context` | quanto è pieno il contesto e da cosa |
| `/compact` | riassume la conversazione per liberare contesto |
| `/clear` | conversazione nuova per un compito nuovo |
| `/btw domanda` | domanda veloce che non entra nella conversazione |
| `/tasks` | lavori in background (comandi, sotto-agenti) |
| `/diff` | rivedi le modifiche non ancora committate |
| `/code-review` | cerca bug nelle modifiche attuali (--fix per correggerli) |
| `/security-review` | cerca vulnerabilità nelle modifiche del branch |
| `/rewind` | riporta codice e conversazione a un punto precedente |
| `/resume` | riprende una conversazione passata |
| `/usage` | consumi e limiti del piano |
| `/status` | versione, modello, account |
| `/mcp` | gestisce i server MCP |
| `/skills` | elenca le skill |
| `/doctor` | controlla e ripara l'installazione |
| `/export` | salva la conversazione come testo |
| `/login` | login (nel container: la prima volta, poi resta nel volume) |
| `/exit` | esce |

## Modalità di permesso (Shift+Tab)

| Modalità | Cosa può fare e quando |
| --- | --- |
| `Manual` | solo leggere, chiede per file e comandi: sul PC e nei progetti che non conosci |
| `acceptEdits` | modifica i file senza chiedere: su un branch di feature, rivedendo in lazygit |
| `plan` | legge e propone un piano: all'inizio di ogni feature |
| `auto` | decide da solo con un controllo di sicurezza: dentro un DevContainer, compiti lunghi |
| `bypassPermissions` | tutto senza controlli: solo in un container usa e getta, mai sul PC |

## File di configurazione

| File | Cosa ci metti |
| --- | --- |
| `CLAUDE.md` | nel progetto, da committare: stack, comandi di test e build, convenzioni |
| `~/.claude/CLAUDE.md` | regole personali per tutti i progetti |
| `.claude/settings.json` | permessi e hook del progetto, per il team |
| `.claude/settings.local.json` | eccezioni personali del progetto (non si committa) |
| `~/.claude/settings.json` | preferenze generali |
| `~/.claude/skills/nome/SKILL.md` | procedure personali richiamabili con /nome |
| `.claude/skills/nome/SKILL.md` | procedure del progetto, per il team |
