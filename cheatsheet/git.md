# Git

## Configurazione

| Comando | Cosa fa |
| --- | --- |
| `git config --global user.name "Nome Cognome"` | imposta il nome dei tuoi commit (una volta per PC) |
| `git config --global user.email "email"` | imposta l'email dei commit: usa quella dell'account GitHub |
| `git config --global init.defaultBranch main` | i nuovi repository partono dal branch main |
| `git config --global core.editor nvim` | Neovim come editor dei messaggi |
| `git config --global --list` | mostra la configurazione attuale |
| `git config --global alias.st status` | alias: da qui `git st` |
| `git config --global alias.lg "log --oneline --graph --all"` | alias: da qui `git lg` |
| `git init` | trasforma la cartella attuale in un repository |
| `git clone URL` | scarica un repository esistente in una nuova cartella |

## Il ciclo di ogni giorno

| Comando | Cosa fa |
| --- | --- |
| `git status` | file modificati, pronti per il commit o nuovi; quasi sempre suggerisce anche il comando per uscire dalla situazione |
| `git diff` | modifiche non ancora aggiunte |
| `git diff --staged` | modifiche già aggiunte, che entreranno nel commit |
| `git add file` | aggiunge un file al prossimo commit |
| `git add -p` | aggiunge un pezzo alla volta chiedendo y/n per ogni blocco: ottimo per i micro commit |
| `git add .` | aggiunge tutto quello che è cambiato nella cartella |
| `git commit -m "messaggio"` | salva il commit con un messaggio breve |
| `git commit` | apre Neovim per scrivere un messaggio più lungo |
| `git restore --staged file` | toglie un file dal prossimo commit, senza perdere le modifiche |
| `git mv vecchio nuovo` | rinomina un file tenendone traccia |
| `git rm file` | elimina un file tenendone traccia |
| `git rm --cached file` | smette di tracciare un file già committato (poi mettilo nel .gitignore) |

## Branch

| Comando | Cosa fa |
| --- | --- |
| `git branch` | elenca i branch locali (* = quello attuale) |
| `git branch -a` | elenca anche i branch remoti |
| `git switch nome` | passa a un branch esistente |
| `git switch -c nome` | crea un branch nuovo e ci passa |
| `git merge nome` | unisce nome nel branch attuale, con un commit di unione |
| `git rebase develop` | rimette i tuoi commit in cima a develop aggiornato; solo su branch che hai solo tu |
| `git branch -d nome` | elimina un branch già unito |
| `git branch -D nome` | elimina un branch anche se non è unito (perdi i suoi commit) |
| `git push origin --delete nome` | elimina il branch su GitHub |

## Remoti

| Comando | Cosa fa |
| --- | --- |
| `git remote -v` | mostra i remoti collegati (di solito origin) |
| `git fetch` | scarica le novità dal remoto senza toccare i tuoi file |
| `git pull` | scarica e unisce le novità nel branch attuale (fetch + merge) |
| `git push` | invia i tuoi commit al remoto |
| `git push -u origin nome` | primo push di un branch nuovo: lo crea su GitHub e lo collega |

## Vedere la storia

| Comando | Cosa fa |
| --- | --- |
| `git log --oneline` | un commit per riga, dal più recente |
| `git log --oneline --graph --all` | tutti i branch con il grafico di come si separano e si uniscono |
| `git log -p file` | storia di un file con le modifiche di ogni commit |
| `git log --author="Federico"` | solo i commit di un autore |
| `git show hash` | dettagli e modifiche di un commit (bastano i primi 7 caratteri) |
| `git blame file` | chi ha modificato per ultimo ogni riga, e in quale commit |
| `j / k, /, q` | nel log: scorri, cerca, esci (come in Neovim) |

## Annullare e rimediare

| Comando | Cosa fa |
| --- | --- |
| `git restore file` | butta le modifiche a un file; irreversibile per le modifiche non committate |
| `git restore --staged file` | hai aggiunto un file per sbaglio: lo togli, le modifiche restano |
| `git add file && git commit --amend` | corregge messaggio o file dimenticati nell'ultimo commit; solo prima del push |
| `git reset --soft HEAD~1` | disfa l'ultimo commit tenendo le modifiche pronte |
| `git revert hash` | annulla un commit già pushato con un nuovo commit, senza riscrivere la storia |
| `git reflog` | elenca dove è stato HEAD: ritrovi commit e branch persi |
| `git switch -c recupero hash` | recupera un commit perso trovato con reflog |
| `git stash` | mette da parte il lavoro a metà per cambiare branch |
| `git stash pop` | riprende l'ultimo lavoro messo da parte |
| `git stash list` | elenca gli stash |
| `git stash drop` | elimina l'ultimo stash |
| `git rebase --abort` | annulla un rebase andato storto |
| `git merge --abort` | annulla un merge andato storto |
| `git rebase --continue` | continua il rebase dopo aver risolto un conflitto (git add file) |
| `git reset --hard` | torna esattamente all'ultimo commit cancellando le modifiche non committate |

## Git Flow, passo per passo

| Comando | Cosa fa |
| --- | --- |
| `git switch develop && git pull` | 1. parti da develop aggiornato |
| `git switch -c feature/nome-breve` | 2. crea il branch della feature |
| `git add -p && git commit -m "feat: ..."` | 3. lavora a micro commit |
| `git push -u origin feature/nome-breve` | 4. pubblica il branch |
| `gh pr create --base develop` | 5. apri la PR verso develop |
| `git switch develop && git pull && git branch -d feature/nome-breve` | 6. dopo il merge, pulisci |
