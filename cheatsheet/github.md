# GitHub

## gh, la CLI di GitHub

| Comando | Cosa fa |
| --- | --- |
| `gh auth login` | collega gh al tuo account; da lì anche git push usa quelle credenziali |
| `gh repo clone utente/repo` | clona un repository |
| `gh pr create --base develop` | apre una pull request verso develop |
| `gh pr list` | elenca le pull request aperte |
| `gh pr view --web` | apre nel browser la PR del branch attuale |
| `gh pr checkout 12` | scarica la PR numero 12 per provarla in locale |
| `gh pr merge` | unisce la PR |
| `gh completion -s zsh > ~/.oh-my-zsh/completions/_gh` | completamento con Tab per gh (poi `rm -f ~/.zcompdump*` e `exec zsh`) |

## Nomi dei branch

| Nome | Quando |
| --- | --- |
| `feature/nome-breve` | nuova funzionalità, parte da develop |
| `fix/nome-breve` | correzione di un bug |
| `refactor/nome-breve` | riordino del codice senza cambiare comportamento |
| `test/nome-breve` | solo test |
| `docs/nome-breve` | solo documentazione |
| `chore/nome-breve` | strumenti, dipendenze, configurazione |
| `hotfix/nome-breve` | correzione urgente in produzione: parte da main |
| `feature/42-nome-breve` | con il numero della issue collegata |
| `minuscolo, kebab-case, breve` | regola per tutti: feature/vault-encryption, fix/login-redirect-loop |

## Messaggi dei commit (Conventional Commits)

| Formato | Cosa vuol dire |
| --- | --- |
| `tipo(ambito): descrizione` | in inglese, all'imperativo, max 72 caratteri, senza punto finale; l'ambito è facoltativo |
| `riga vuota + corpo` | dopo l'oggetto, spiega cosa e perché se serve |
| `feat: ...` | nuova funzionalità: aumenta la minor (1.2.0 → 1.3.0) |
| `fix: ...` | correzione di un bug: aumenta la patch (1.2.0 → 1.2.1) |
| `perf: ...` | miglioramento delle prestazioni: aumenta la patch |
| `feat!: ...` | cambiamento incompatibile: aumenta la major (1.2.0 → 2.0.0) |
| `BREAKING CHANGE: ...` | nel piè di pagina: come il `!`, aumenta la major |
| `test: ...` | solo test: nessun rilascio |
| `refactor: ...` | riordino senza cambiare comportamento: nessun rilascio |
| `docs: ...` | documentazione: nessun rilascio |
| `chore: ...` | manutenzione, dipendenze, configurazione: nessun rilascio |
| `style: ...` | formattazione, senza cambiare il codice: nessun rilascio |
| `build: ...` / `ci: ...` | sistema di build / pipeline CI: nessun rilascio |
| `Refs: #42` | nel piè di pagina: collega la issue |
| `feat(vault): implement AES-GCM entry encryption` | esempio di commit completo |
| `test(vault): add failing test for entry encryption` | esempio di commit TDD (fase rossa) |

## Pull request

| Regola | Cosa vuol dire |
| --- | --- |
| `titolo come un commit` | stesso formato: feat(docs): add cheatsheet popup |
| `descrizione` | riassunto, motivazione, come è stato testato, note per chi rivede |
| `feature → develop` | ogni branch di lavoro entra in develop solo con una PR |
| `develop → main, titolo "chore: release"` | PR di rilascio; poi release-please apre la PR con versione e CHANGELOG |
| `main → develop` | back-merge subito dopo ogni rilascio, per riportare versione e CHANGELOG |
| `merge commit o rebase, mai squash` | così restano i micro commit e release-please li legge tutti |
| `git fetch && git rebase origin/develop` | aggiorna il branch prima di aprire la PR se develop è andato avanti |

## Regole di Git Flow

| Regola | Perché |
| --- | --- |
| `mai push diretto su main o develop` | ci si arriva solo con una PR |
| `mai force-push su main o develop` | riscriverebbe la storia condivisa |
| `una feature = un branch` | non mischiare modifiche che non c'entrano |
| `mai --no-verify` | non saltare gli hook di controllo |
| `niente versioni o CHANGELOG a mano` | li calcola release-please dai messaggi dei commit |
