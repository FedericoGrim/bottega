# DevContainer

## Comandi di Bottega

| Comando | Cosa fa |
| --- | --- |
| `dev-c-c` | apre il progetto in un dev container, con Claude Code sul PC |
| `dev-c-o` | come sopra, con OpenCode |
| `dev-c-o --agent-in-container` | anche l'agente gira dentro il container |
| `dev-up [cartella]` | avvia il container del progetto; se manca devcontainer.json ne genera uno base |
| `dev-in [comando]` | esegue un comando nel container (senza comando apre bash); sul PC se non c'è container |
| `dev-in psql -h db -U app app` | entra nel database (se psql è nel container) |
| `dev-personal-setup` | aggiorna Neovim, configurazione e agenti montati nei container |
| `dev-stop -k` | chiude le sessioni e ferma anche i container |
| `Alt+n` | nella zona terminali: nuova shell nel container |

## dctl (CLI devcontainer)

| Comando | Cosa fa |
| --- | --- |
| `dctl up --workspace-folder .` | avvia il container senza lo schema: deve stampare "outcome":"success" |
| `dctl up --workspace-folder . --remove-existing-container` | ricostruisce dopo aver cambiato .devcontainer/; i dati nei volumi restano |
| `dctl exec --workspace-folder . bash` | apre una shell nel container |

## File del progetto

| File | A cosa serve |
| --- | --- |
| `.devcontainer/devcontainer.json` | quale servizio è l'ambiente di sviluppo, quali servizi avviare, quali strumenti |
| `.devcontainer/compose.yaml` | descrive i container: app, database, identity provider |
| `.devcontainer/Dockerfile` | solo se l'immagine base non basta |
| `.devcontainer/post-create.sh` | installa le dipendenze del progetto la prima volta |
| `.env.example` | variabili d'esempio; il vero .env è nel .gitignore |
| `runServices` | in devcontainer.json: cosa parte con il container |
| `profiles: ["nome"]` | in compose.yaml: servizio spento finché non lo accendi |
| `127.0.0.1:8000:8000` | porte pubblicate solo sul PC, mai su tutta la rete |
| `db:5432` | dal container i servizi si chiamano per nome, non localhost |
| `--host 0.0.0.0` | il server deve ascoltare su tutte le interfacce per essere visto dal browser del PC |

## Controlli e problemi

| Comando | Cosa fa |
| --- | --- |
| `podman ps -a` | stato dei container |
| `podman logs nome` | cosa dice un servizio |
| `~/.cache/dev/<progetto>.json` | stato del container usato da dev-in (id, utente, cartella) |
| `ls -ln file` | controlla che i file creati nel container siano tuoi (stesso numero di id -u) |
| `dev-in bash -c 'command -v claude'` | controlla che Claude Code sia installato nel container |
| `:checkhealth` | in LazyVim nel container: cosa manca |

## Strumenti utili

| Comando | Cosa fa |
| --- | --- |
| `pgcli -h 127.0.0.1 -U app app` | client Postgres con autocompletamento (pipx install pgcli) |
| `dive podman://nome:tag` | vede i livelli di un'immagine e cosa pesa |
| `hadolint Dockerfile` | controlla i Dockerfile (da :Mason in LazyVim) |
| `docker-compose version` | controlla che Compose sia nel PATH |
| `devcontainer --version` | controlla la CLI dei DevContainer |
