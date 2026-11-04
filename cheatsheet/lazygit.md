# lazygit

## Riquadri

| Tasto | Cosa mostra |
| --- | --- |
| `1` | Status: nome del repository e branch attuale |
| `2` | Files: file modificati, pronti o meno per il commit |
| `3` | Branches: branch locali, remoti e tag |
| `4` | Commits: storia dei commit del branch attuale |
| `5` | Stash: modifiche messe da parte |

## Tasti globali

| Tasto | Cosa fa |
| --- | --- |
| `h / l` | riquadro precedente / successivo (anche frecce sinistra/destra) |
| `j / k` | muoversi nell'elenco (anche frecce su/giù) |
| `?` | tutti i tasti del riquadro attuale |
| `/` | filtra o cerca nell'elenco |
| `Esc` | annulla, torna indietro, esce da un filtro |
| `z / Shift+z` | annulla / ripristina l'ultima azione su commit e branch (non le modifiche scartate) |
| `+ / _` | ingrandisce / riduce la vista (utile nel pannello stretto) |
| `P` | push; al primo push di un branch nuovo crea anche il collegamento |
| `p` | pull |
| `:` | lancia un comando di shell qualsiasi |
| `q` | esce da lazygit |
| `Shift+g` | apre nel browser la PR del branch (serve gh con login fatto) |

## File e commit (riquadro 2)

| Tasto | Cosa fa |
| --- | --- |
| `Spazio` | mette o toglie il file dal prossimo commit (stage / unstage) |
| `a` | mette o toglie tutti i file |
| `Invio` | apre il file per scegliere singole righe da includere |
| `c` | commit con un messaggio breve |
| `C` | commit scrivendo il messaggio in Neovim |
| `A` | aggiunge le modifiche all'ultimo commit (amend) |
| `d` | scarta le modifiche del file (chiede conferma) |
| `e / o` | modifica il file / lo apre con il programma predefinito |
| `i` | aggiunge il file a .gitignore |
| `` ` `` | alterna vista ad albero e vista a elenco |
| `f` | scarica le novità senza applicarle (fetch) |
| `s` | mette da parte tutte le modifiche (stash) |

## Dentro un file aperto

| Tasto | Cosa fa |
| --- | --- |
| `Spazio` | stage / unstage della riga |
| `v` | inizia a selezionare un gruppo di righe |
| `a` | seleziona l'intero blocco di modifiche (hunk) |
| `Tab` | passa tra modifiche non pronte e pronte |
| `Esc` | torna all'elenco dei file |
| `b` | in un conflitto: tiene entrambe le versioni (Spazio tiene quella selezionata) |

## Branch (riquadro 3)

| Tasto | Cosa fa |
| --- | --- |
| `Spazio` | passa al branch selezionato (checkout) |
| `n` | crea un nuovo branch da quello selezionato (su develop: feature/nome) |
| `M` | unisce il branch selezionato in quello attuale (merge) |
| `r` | ribasa il branch attuale sopra quello selezionato (rebase) |
| `R` | rinomina il branch |
| `d` | elimina il branch (locale o remoto, chiede quale) |
| `f` | aggiorna il branch selezionato dal remoto senza cambiarci (fast-forward) |
| `u` | opzioni per il branch remoto collegato (upstream) |
| `[ / ]` | schede Local branches, Remotes, Tags |
| `i` | opzioni di git-flow, se installato |

## Storia dei commit (riquadro 4)

| Tasto | Cosa fa |
| --- | --- |
| `Invio` | mostra i file cambiati in quel commit |
| `r` | cambia il messaggio del commit (reword) |
| `s` | unisce il commit a quello sotto tenendo i messaggi (squash) |
| `f` | unisce il commit a quello sotto scartando il suo messaggio (fixup) |
| `d` | elimina il commit (drop) |
| `Ctrl+j / Ctrl+k` | sposta il commit giù / su |
| `Shift+a` | aggiunge le modifiche pronte a quel commit, anche se non è l'ultimo |
| `Shift+c / Shift+v` | copia un commit / lo incolla su un altro branch (cherry-pick) |
| `t` | crea un commit che annulla quello selezionato (revert) |
| `g` | opzioni di reset al commit selezionato |
| `y` | copia hash, messaggio o altro del commit |

## Stash (riquadro 5)

| Tasto | Cosa fa |
| --- | --- |
| `Spazio` | riapplica lo stash selezionato e lo tiene |
| `g` | riapplica lo stash e lo elimina (pop) |
| `d` | elimina lo stash |

## Configurazione

| Cosa | Cosa fa |
| --- | --- |
| `~/.config/lazygit/config.yml` | file di configurazione di lazygit |
| `git.paging.pager: delta --dark --paging=never` | riga del config: lazygit mostra i diff con delta |
| `git.paging.colorArg: always` | riga del config: serve perché delta mantenga i colori |
