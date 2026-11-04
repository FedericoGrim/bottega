# LazyVim

## Modalità

| Tasto | Cosa fa |
| --- | --- |
| `Esc` | torna alla modalità normale: quando sei confuso, premilo |
| `i / a` | scrivi prima / dopo il cursore |
| `I / A` | scrivi all'inizio / alla fine della riga |
| `o / O` | scrivi su una nuova riga sotto / sopra |
| `v` | selezione per caratteri |
| `V` | selezione per righe intere |
| `Ctrl+v` | selezione a blocco rettangolare |
| `:` | riga di comando: salvare, uscire, sostituire |

## Muoversi nel file

| Tasto | Cosa fa |
| --- | --- |
| `h j k l` | sinistra, giù, su, destra; un numero davanti ripete (5j) |
| `w / b` | parola successiva / precedente |
| `e` | fine della parola |
| `0 / ^ / $` | inizio riga / primo carattere non vuoto / fine riga |
| `gg / G` | inizio / fine del file |
| `42G oppure :42` | vai alla riga 42 |
| `Ctrl+d / Ctrl+u` | mezza pagina giù / su |
| `{ / }` | paragrafo precedente / successivo |
| `%` | salta alla parentesi corrispondente |
| `f + carattere` | salta al prossimo carattere sulla riga (fx) |
| `t + carattere` | come f, ma si ferma subito prima |
| `; / ,` | ripete l'ultimo f/t in avanti / indietro |
| `Ctrl+o / Ctrl+i` | torna indietro / avanti tra i punti in cui sei saltato |

## Modificare il testo

| Tasto | Cosa fa |
| --- | --- |
| `x` | cancella il carattere sotto il cursore |
| `dd` | cancella la riga (resta in memoria, puoi incollarla) |
| `D` | cancella fino a fine riga |
| `cc / C` | riscrive la riga / da qui a fine riga |
| `cw` | riscrive la parola |
| `dw / d$ / y3j` | operatore + movimento: cancella parola, fino a fine riga, copia 4 righe |
| `yy` | copia la riga |
| `p / P` | incolla dopo / prima del cursore |
| `u / Ctrl+r` | annulla / ripristina |
| `.` | ripete l'ultima modifica |
| `r + carattere` | sostituisce un solo carattere |
| `J` | unisce la riga sotto a questa |
| `>> / <<` | indenta / toglie indentazione |
| `ciw` | riscrive la parola su cui sei, ovunque sia il cursore |
| `ci" / ci'` | riscrive il testo tra virgolette |
| `di( / da(` | cancella dentro le parentesi / parentesi comprese |
| `ci{` | riscrive il corpo di un blocco { } |
| `yap` | copia il paragrafo |
| `cit` | riscrive il contenuto di un tag HTML/JSX |

## Cercare e sostituire

| Comando | Cosa fa |
| --- | --- |
| `/testo + Invio` | cerca in avanti |
| `?testo + Invio` | cerca all'indietro |
| `n / N` | risultato successivo / precedente |
| `* / #` | cerca la parola sotto il cursore, avanti / indietro |
| `:s/vecchio/nuovo/` | sostituisce la prima occorrenza nella riga |
| `:%s/vecchio/nuovo/g` | sostituisce in tutto il file |
| `:%s/vecchio/nuovo/gc` | come sopra, chiedendo conferma per ognuna |
| `Spazio s r` | cerca e sostituisci in più file del progetto |

## File, buffer e finestre

| Comando | Cosa fa |
| --- | --- |
| `:w` | salva |
| `:q` | chiude la finestra |
| `:wq oppure :x` | salva e chiude |
| `:q!` | chiude senza salvare (bloccato? Esc Esc poi :q!) |
| `:wa / :qa` | salva tutto / chiude tutto |
| `:e percorso/file` | apre un file |
| `Shift+h / Shift+l` | buffer precedente / successivo |
| `Spazio b d` | chiude il buffer corrente |
| `Spazio \| / Spazio -` | divide la finestra a destra / sotto |
| `Ctrl+h Ctrl+j Ctrl+k Ctrl+l` | passa alla finestra a sinistra, sotto, sopra, a destra |
| `Spazio w d` | chiude la finestra |
| `Spazio q q` | esce da Neovim |

## Trovare cose

| Tasti | Cosa fa |
| --- | --- |
| `Spazio` | menu di tutti i comandi: premilo e aspetta un attimo |
| `Spazio Spazio` | cerca un file per nome nel progetto |
| `Spazio /` | cerca un testo in tutti i file del progetto |
| `Spazio e` | apre/chiude l'esplora file laterale |
| `Spazio f r` | file aperti di recente |
| `Spazio ,` | elenco dei buffer aperti |

## Codice (LSP)

| Tasti | Cosa fa |
| --- | --- |
| `gd` | vai alla definizione |
| `gr` | trova dove è usato (riferimenti) |
| `K` | mostra la documentazione del simbolo |
| `Spazio c a` | code action: import mancanti, correzioni rapide |
| `Spazio c r` | rinomina il simbolo in tutto il progetto |
| `Spazio c f` | formatta il file |
| `]d / [d` | errore o avviso successivo / precedente |
| `Spazio x x` | elenco di tutti gli errori del progetto |

## Debug

| Tasti | Cosa fa |
| --- | --- |
| `Spazio d b` | mette o toglie un punto di interruzione |
| `Spazio d B` | punto di interruzione con una condizione |
| `Spazio d c` | avvia il debug o continua fino al prossimo punto |
| `Spazio d i` | entra nella funzione (step into) |
| `Spazio d O` | esegue la riga senza entrare (step over) |
| `Spazio d o` | esce dalla funzione (step out) |
| `Spazio d C` | continua fino alla riga del cursore |
| `Spazio d u` | apre o chiude il pannello del debug |
| `Spazio d e` | valuta l'espressione sotto il cursore |
| `Spazio d r` | apre o chiude la console (REPL) |
| `Spazio d t` | termina il debug |

## Test

| Tasti | Cosa fa |
| --- | --- |
| `Spazio t r` | esegue il test più vicino al cursore |
| `Spazio t t` | esegue tutti i test del file |
| `Spazio t T` | esegue tutti i test del progetto |
| `Spazio t l` | ripete l'ultimo test eseguito |
| `Spazio t s` | apre o chiude il riepilogo dei test |
| `Spazio t o` | mostra l'output del test |
| `Spazio t d` | esegue il test più vicino con il debugger |
| `Spazio t w` | rilancia i test del file a ogni salvataggio |
| `Spazio t S` | ferma i test in corso |

## Refactoring e rinomina

| Tasti | Cosa fa |
| --- | --- |
| `Spazio c r` | rinomina il simbolo con anteprima in diretta |
| `Spazio r s` | menu dei refactoring disponibili |
| `Spazio r f` | estrae il codice selezionato in una funzione |
| `Spazio r x` | estrae il codice selezionato in una variabile |
| `Spazio r i` | sostituisce una variabile con il suo valore |
| `Spazio c o` | Java: ordina gli import |
| `Spazio c x v` | Java: estrae una variabile |
| `Spazio c x c` | Java: estrae una costante |

## GitHub (Octo)

| Tasti | Cosa fa |
| --- | --- |
| `Spazio g i` | elenco delle issue del repository |
| `Spazio g I` | cerca tra le issue |
| `Spazio g p` | elenco delle pull request |
| `Spazio g P` | cerca tra le pull request |
| `Spazio g r` | elenco dei repository |
| `Spazio g S` | cerca su GitHub |
| `:Octo pr create` | crea una pull request dal branch corrente |

## Strumenti

| Tasti | Cosa fa |
| --- | --- |
| `Spazio g g` | apre lazygit a tutto schermo; q per chiuderlo |
| `Ctrl+/` | apre/chiude un terminale flottante |
| `:LazyExtras` | attiva i linguaggi (lang.python, lang.typescript, ...): x sulla riga |
| `Spazio l oppure :Lazy` | gestione plugin: U aggiorna, S sincronizza, q chiude |
| `Spazio c m` | Mason: installa server LSP e formatter |
| `:checkhealth vim.lsp` | quali server sono attivi nel file aperto e perché |
| `:MasonInstall nome` | installa un server, un debugger o un formatter |
| `:MasonInstall roslyn@5.14.0-1.26552.12` | C#: installa Roslyn se l'ultima versione non si scarica |
| `:checkhealth` | controlla cosa manca (compilatore, tree-sitter, clipboard) |
| `:Tutor` | corso interattivo delle basi, mezz'ora |
| `:lua Snacks.dashboard()` | torna alla schermata iniziale |
| `vim.keymap.set("i", "jk", "<Esc>")` | in keymaps.lua: jk veloce torna in modalità normale |
