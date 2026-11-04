# tmux e Bottega

## Comandi di Bottega

| Comando | Cosa fa |
| --- | --- |
| `dev [cartella]` | apre l'ambiente del progetto (o ci rientra se esiste già), con Claude Code |
| `dev-o` | come dev, con OpenCode |
| `dev-c-c / dev-c-o` | progetto in un dev container, con Claude Code / OpenCode |
| `dev --help` | opzioni ed elenco di tutti i comandi |
| `dev-stop` | chiude le sessioni tmux: principale, laterale e terminali; i container restano accesi |
| `dev-stop -k` | come sopra, e ferma anche i container |
| `dev-docs` | apre questa guida (anche con Ctrl+b g) |
| `./install.sh` | dalla cartella di Bottega: reinstalla script, guida e scelte |

## Schema principale (prefisso Ctrl+b)

| Tasto | Cosa fa |
| --- | --- |
| `Ctrl+b g` | apre questa guida |
| `Ctrl+b frecce oppure h j k l` | passa al pannello a sinistra, sotto, sopra, a destra |
| `Ctrl+b o` | pannello successivo, in ordine |
| `Ctrl+b ;` | torna all'ultimo pannello in cui eri |
| `Ctrl+b q + numero` | mostra i numeri dei pannelli e salta a quello scelto |
| `Ctrl+b z` | ingrandisce o riduce il pannello attivo |
| `Ctrl+b \| / Ctrl+b -` | divide il pannello affiancato / sotto |
| `Ctrl+b x` | chiude il pannello (chiede conferma) |
| `Ctrl+b d` | si stacca lasciando tutto acceso; rientri con dev |
| `Ctrl+b s` | elenco delle sessioni, per cambiare progetto |
| `Ctrl+b c` | nuova finestra sul PC |
| `Ctrl+b n / Ctrl+b p` | finestra successiva / precedente |
| `Ctrl+b w` | elenco di tutto |
| `Ctrl+b [` | scorrimento per rileggere l'output (q per uscire) |
| `Ctrl+b :` | riga di comando di tmux (es. kill-session) |
| `Ctrl+b r` | ricarica ~/.tmux.conf |
| `Ctrl+b D` | podman-tui in una finestra a comparsa |
| `mouse` | clic per scegliere il pannello, trascina i bordi per ridimensionare |

## Pannello laterale (senza prefisso)

| Tasto | Cosa fa |
| --- | --- |
| `Alt+1` | agente (Claude o OpenCode) |
| `Alt+2` | lazygit |
| `Alt+3` | pannello dei container (podman-tui o lazydocker) |

## Zona terminali (prefisso Ctrl+a)

| Tasto | Cosa fa |
| --- | --- |
| `Alt+n` | nuovo terminale: nel container se il progetto ne ha uno |
| `Alt+← / Alt+→` | terminale precedente / successivo |
| `Alt+r` | rinomina il terminale (es. backend) |
| `Alt+x` | chiude il terminale, con conferma |

## Server tmux

| Comando | Cosa fa |
| --- | --- |
| `tmux ls` | elenca le sessioni (una per progetto) |
| `tmux kill-server` | spegne il tmux principale |
| `tmux -L terminals kill-server` | spegne il tmux della zona terminali |
| `tmux -L side kill-server` | spegne il tmux del pannello laterale |
| `tmux -L side show-hooks -t progetto` | controlla l'aggancio che cambia la larghezza del pannello |
| `~/.cache/dev/side-width.log` | log dei cambi di larghezza del pannello laterale |
