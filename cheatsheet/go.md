# Go

## Progetto

| Comando | Cosa fa |
| --- | --- |
| `go version` | versione di Go |
| `go mod init github.com/utente/progetto` | crea go.mod |
| `go get nome@latest` | aggiunge o aggiorna una dipendenza |
| `go mod tidy` | pulisce e allinea go.mod |
| `go list -m -u all` | dipendenze da aggiornare |

## Esecuzione e build

| Comando | Cosa fa |
| --- | --- |
| `go run .` | compila e avvia |
| `go build` | compila |
| `go build -o bin/app ./cmd/app` | compila in un file preciso |
| `go install ./...` | installa i programmi in $GOPATH/bin |
| `GOOS=linux GOARCH=amd64 go build` | compila per un'altra piattaforma |

## Test e qualità

| Comando | Cosa fa |
| --- | --- |
| `go test ./...` | esegue tutti i test |
| `go test -run NomeTest ./...` | esegue solo i test che corrispondono |
| `go test -v ./...` | mostra ogni test |
| `go test -race ./...` | cerca race condition |
| `go test -cover ./...` | mostra la copertura |
| `go test -bench . ./...` | esegue i benchmark |
| `go fmt ./...` | formatta il codice |
| `go vet ./...` | cerca errori comuni |
| `go doc nome` | mostra la documentazione |
