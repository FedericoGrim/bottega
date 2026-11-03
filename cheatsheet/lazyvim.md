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

## Strumenti

| Tasti | Cosa fa |
| --- | --- |
| `Spazio g g` | apre lazygit a tutto schermo; q per chiuderlo |
| `Ctrl+/` | apre/chiude un terminale flottante |
| `:LazyExtras` | attiva i linguaggi (lang.python, lang.typescript, ...): x sulla riga |
| `Spazio l oppure :Lazy` | gestione plugin: U aggiorna, S sincronizza, q chiude |
| `Spazio c m` | Mason: installa server LSP e formatter |
| `:checkhealth` | controlla cosa manca (compilatore, tree-sitter, clipboard) |
| `:Tutor` | corso interattivo delle basi, mezz'ora |
| `:lua Snacks.dashboard()` | torna alla schermata iniziale |
| `vim.keymap.set("i", "jk", "<Esc>")` | in keymaps.lua: jk veloce torna in modalità normale |
