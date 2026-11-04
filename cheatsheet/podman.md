# Podman

## podman-tui

| Tasto | Cosa fa |
| --- | --- |
| `F1` | aiuto |
| `F2` | sistema: versione, memoria |
| `F3` | pod |
| `F4` | container |
| `F5 / F6` | volumi / immagini |
| `F7 / F8` | reti / segreti |
| `m` | menu dei comandi per l'elemento selezionato |
| `Ctrl+c` | esce |
| `Alt+3` | nel pannello laterale: scheda dei container |
| `Ctrl+b z` | ingrandisce il pannello quando la tabella è tagliata |

## Comandi di tutti i giorni

| Comando | Cosa fa |
| --- | --- |
| `podman ps` | container accesi |
| `podman ps -a` | tutti i container, anche fermi |
| `podman stats --no-stream` | consumi di CPU e RAM: chi pesa di più |
| `podman logs -f nome` | log in diretta di un container |
| `podman stop nome` | ferma un container (aiuta anche la batteria) |
| `podman start nome` | riavvia un container fermo |
| `podman rm nome` | elimina un container |
| `podman exec -it nome bash` | entra in un container |
| `podman images` | elenco delle immagini |
| `podman system df` | spazio usato da immagini, container e volumi |
| `podman volume ls` | elenco dei volumi |
| `podman volume export nome -o nome.tar` | salva un volume in un file |
| `podman volume import nome nome.tar` | rimette un file in un volume |
| `podman save -o immagine.tar nome:tag` | salva un'immagine in un file |
| `podman info \| grep -iE 'networkBackend\|cgroupVersion\|databaseBackend'` | versione e configurazione del motore |
| `podman inspect nome` | tutti i dettagli di un container (mount, rete, etichette) |

## Liberare spazio

| Comando | Cosa fa |
| --- | --- |
| `podman image prune -a` | elimina le immagini non usate: si riscaricano, fallo per primo |
| `podman volume prune` | ATTENZIONE: elimina tutti i volumi non collegati, anche i database dei progetti spenti |
| `podman volume rm nome` | elimina un solo volume: solo se sai di che progetto è |

## Socket e configurazione

| Comando | Cosa fa |
| --- | --- |
| `systemctl --user enable --now podman.socket` | attiva il socket: serve a podman-tui, Compose e lazydocker |
| `systemctl --user status podman.socket` | controlla che il socket sia attivo |
| `systemctl --user restart podman.socket` | riavvia il socket dopo aver cambiato containers.conf |
| `podman info --format '{{.Host.Security.Rootless}}'` | deve stampare true: Podman è rootless |
| `podman completion zsh > ~/.oh-my-zsh/completions/_podman` | completamento con Tab (poi `rm -f ~/.zcompdump*` e `exec zsh`) |
| `docker.io/library/postgres:17` | usa sempre nomi di immagine completi di registry |
